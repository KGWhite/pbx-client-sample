/// Bloc that orchestrates call control operations.
library;

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pbx_client_sample/domain/entities/call_entity.dart';
import 'package:pbx_client_sample/domain/repositories/call_repository.dart';
import 'call_event.dart';
import 'call_state.dart';

export 'call_event.dart';
export 'call_state.dart';

class CallBloc extends Bloc<CallEvent, CallState> {
  final CallRepository _callRepository;
  StreamSubscription<CallEntity>? _callSubscription;

  CallBloc({required CallRepository callRepository})
      : _callRepository = callRepository,
        super(const CallIdle()) {
    on<CallStarted>(_onCallStarted);
    on<CallAnswered>(_onCallAnswered);
    on<CallEnded>(_onCallEnded);
    on<CallMuteToggled>(_onMuteToggled);
    on<CallHoldToggled>(_onHoldToggled);
    on<CallDtmfSent>(_onDtmfSent);
    on<CallStateUpdated>(_onCallStateUpdated);

    // Listen to the SIP/WebRTC service stream
    _callSubscription = _callRepository.callStream.listen(
      (call) => add(CallStateUpdated(call)),
    );
  }

  Future<void> _onCallStarted(
    CallStarted event,
    Emitter<CallState> emit,
  ) async {
    try {
      final call = await _callRepository.makeCall(event.destination);
      emit(CallInProgress(call));
    } catch (e) {
      emit(CallError(e.toString()));
    }
  }

  Future<void> _onCallAnswered(
    CallAnswered event,
    Emitter<CallState> emit,
  ) async {
    await _callRepository.answerCall(event.sessionId);
  }

  Future<void> _onCallEnded(
    CallEnded event,
    Emitter<CallState> emit,
  ) async {
    await _callRepository.hangupCall(event.sessionId);
    emit(const CallTerminated());
  }

  Future<void> _onMuteToggled(
    CallMuteToggled event,
    Emitter<CallState> emit,
  ) async {
    await _callRepository.toggleMute(event.sessionId, mute: event.mute);
    if (state is CallActive) {
      final current = (state as CallActive).call;
      emit(CallActive(current.copyWith(isMuted: event.mute)));
    }
  }

  Future<void> _onHoldToggled(
    CallHoldToggled event,
    Emitter<CallState> emit,
  ) async {
    await _callRepository.toggleHold(event.sessionId, hold: event.hold);
    if (state is CallActive) {
      final current = (state as CallActive).call;
      emit(CallActive(current.copyWith(isOnHold: event.hold)));
    }
  }

  Future<void> _onDtmfSent(
    CallDtmfSent event,
    Emitter<CallState> emit,
  ) async {
    await _callRepository.sendDtmf(event.sessionId, event.digit);
  }

  Future<void> _onCallStateUpdated(
    CallStateUpdated event,
    Emitter<CallState> emit,
  ) async {
    final call = event.callEntity as CallEntity;
    switch (call.state) {
      case CallEntityState.calling:
      case CallEntityState.ringing:
        emit(CallInProgress(call));
      case CallEntityState.connected:
        emit(CallActive(call));
      case CallEntityState.ended:
        emit(const CallTerminated());
      case CallEntityState.failed:
        emit(const CallError('Call failed'));
      default:
        break;
    }
  }

  @override
  Future<void> close() {
    _callSubscription?.cancel();
    return super.close();
  }
}
