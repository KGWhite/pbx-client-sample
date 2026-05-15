/// Events for the CallBloc.
library;

import 'package:equatable/equatable.dart';

abstract class CallEvent extends Equatable {
  const CallEvent();
  @override
  List<Object?> get props => [];
}

/// User initiates an outgoing call.
class CallStarted extends CallEvent {
  final String destination;
  const CallStarted(this.destination);
  @override
  List<Object?> get props => [destination];
}

/// User answers an incoming call.
class CallAnswered extends CallEvent {
  final String sessionId;
  const CallAnswered(this.sessionId);
  @override
  List<Object?> get props => [sessionId];
}

/// User hangs up.
class CallEnded extends CallEvent {
  final String sessionId;
  const CallEnded(this.sessionId);
  @override
  List<Object?> get props => [sessionId];
}

/// User toggles mute.
class CallMuteToggled extends CallEvent {
  final String sessionId;
  final bool mute;
  const CallMuteToggled(this.sessionId, {required this.mute});
  @override
  List<Object?> get props => [sessionId, mute];
}

/// User toggles hold.
class CallHoldToggled extends CallEvent {
  final String sessionId;
  final bool hold;
  const CallHoldToggled(this.sessionId, {required this.hold});
  @override
  List<Object?> get props => [sessionId, hold];
}

/// User sends a DTMF digit.
class CallDtmfSent extends CallEvent {
  final String sessionId;
  final String digit;
  const CallDtmfSent(this.sessionId, this.digit);
  @override
  List<Object?> get props => [sessionId, digit];
}

/// Internal: state update from the SIP/WebRTC service stream.
class CallStateUpdated extends CallEvent {
  final dynamic callEntity;
  const CallStateUpdated(this.callEntity);
  @override
  List<Object?> get props => [callEntity];
}
