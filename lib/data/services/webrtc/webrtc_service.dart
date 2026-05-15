/// WebRTC service using sip_ua over WSS transport.
///
/// Handles SIP registration, incoming/outgoing call sessions,
/// and media negotiation via flutter_webrtc.
library;

import 'dart:async';

import 'package:sip_ua/sip_ua.dart';
import 'package:pbx_client_sample/core/utils/logger.dart';
import 'package:pbx_client_sample/domain/entities/call_entity.dart';
import 'package:pbx_client_sample/domain/entities/connection_entity.dart';
import 'package:pbx_client_sample/domain/repositories/call_repository.dart';
import 'package:pbx_client_sample/domain/repositories/connection_repository.dart';

/// Implements both [ConnectionRepository] and [CallRepository] for
/// WebRTC (WSS) mode. Uses the sip_ua package as the SIP stack.
class WebRtcService implements SipUaHelperListener, ConnectionRepository, CallRepository {
  final SIPUAHelper _helper = SIPUAHelper();

  final _registrationController =
      StreamController<RegistrationStatus>.broadcast();
  final _callController = StreamController<CallEntity>.broadcast();

  RegistrationStatus _status = RegistrationStatus.unregistered;

  // Map of active call sessions keyed by session ID
  final Map<String, Call> _activeCalls = {};

  WebRtcService() {
    _helper.addSipUaHelperListener(this);
  }

  // ── ConnectionRepository ─────────────────────────────────────────────────

  @override
  RegistrationStatus get currentStatus => _status;

  @override
  Stream<RegistrationStatus> get registrationStream =>
      _registrationController.stream;

  @override
  Future<void> connect(ConnectionEntity config) async {
    final settings = UaSettings();
    settings.webSocketUrl = config.wssUri;
    settings.uri = 'sip:${config.username}@${config.host}';
    settings.authorizationUser = config.username;
    settings.password = config.password;
    settings.displayName = config.displayName;
    settings.userAgent = 'PBX-Client-Flutter/1.0';
    settings.dtmfMode = DtmfMode.RFC2833;

    appLogger.i('[WebRtcService] Connecting to ${config.wssUri}');
    _helper.start(settings);
  }

  @override
  Future<void> disconnect() async {
    appLogger.i('[WebRtcService] Disconnecting');
    _helper.stop();
  }

  // ── CallRepository ────────────────────────────────────────────────────────

  @override
  Stream<CallEntity> get callStream => _callController.stream;

  @override
  Future<CallEntity> makeCall(String destination) async {
    final mediaConstraints = <String, dynamic>{
      'audio': true,
      'video': false,
    };
    _helper.call(destination, voiceonly: true);

    // Return a placeholder; real state comes through callStream
    return CallEntity(
      sessionId: '',
      remoteNumber: destination,
      remoteDisplayName: destination,
      state: CallState.calling,
      startTime: DateTime.now(),
    );
  }

  @override
  Future<void> answerCall(String sessionId) async {
    final call = _activeCalls[sessionId];
    if (call == null) return;
    final mediaConstraints = <String, dynamic>{'audio': true, 'video': false};
    call.answer(_helper.buildCallOptions(voiceonly: true));
  }

  @override
  Future<void> hangupCall(String sessionId) async {
    _activeCalls[sessionId]?.hangup();
  }

  @override
  Future<void> toggleMute(String sessionId, {required bool mute}) async {
    final call = _activeCalls[sessionId];
    if (call == null) return;
    mute ? call.mute() : call.unmute();
  }

  @override
  Future<void> toggleHold(String sessionId, {required bool hold}) async {
    final call = _activeCalls[sessionId];
    if (call == null) return;
    hold ? call.hold() : call.unhold();
  }

  @override
  Future<void> sendDtmf(String sessionId, String digit) async {
    _activeCalls[sessionId]?.sendDTMF(digit);
  }

  // ── SipUaHelperListener callbacks ─────────────────────────────────────────

  @override
  void registrationStateChanged(RegistrationState state) {
    switch (state.state) {
      case RegistrationStateEnum.REGISTERED:
        _updateRegistration(RegistrationStatus.registered);
      case RegistrationStateEnum.UNREGISTERED:
        _updateRegistration(RegistrationStatus.unregistered);
      case RegistrationStateEnum.REGISTRATION_FAILED:
        _updateRegistration(RegistrationStatus.failed);
      default:
        _updateRegistration(RegistrationStatus.registering);
    }
  }

  @override
  void callStateChanged(Call call, CallState2 callState) {
    _activeCalls[call.id] = call;
    _callController.add(_mapCallState(call, callState));
  }

  @override
  void onNewMessage(SIPMessageRequest msg) {}

  @override
  void onNewNotify(Notify ntf) {}

  // ── Helpers ───────────────────────────────────────────────────────────────

  void _updateRegistration(RegistrationStatus status) {
    _status = status;
    _registrationController.add(status);
    appLogger.i('[WebRtcService] Registration: $status');
  }

  CallEntity _mapCallState(Call call, CallState2 sipState) {
    final state = switch (sipState.state) {
      CallStateEnum.CALL_INITIATION => CallState.calling,
      CallStateEnum.PROGRESS => CallState.calling,
      CallStateEnum.ACCEPTED => CallState.connected,
      CallStateEnum.CONFIRMED => CallState.connected,
      CallStateEnum.HOLD => CallState.holding,
      CallStateEnum.UNHOLD => CallState.connected,
      CallStateEnum.FAILED => CallState.failed,
      CallStateEnum.ENDED => CallState.ended,
      CallStateEnum.STREAM => CallState.connected,
      _ => CallState.idle,
    };

    return CallEntity(
      sessionId: call.id ?? '',
      remoteNumber: call.remote_identity ?? '',
      remoteDisplayName: call.remote_display_name ?? '',
      state: state,
      startTime: DateTime.now(),
    );
  }

  void dispose() {
    _registrationController.close();
    _callController.close();
  }
}
