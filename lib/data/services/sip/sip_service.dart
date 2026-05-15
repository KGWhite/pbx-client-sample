/// Standard SIP service using sip_ua over UDP/TCP transport.
///
/// This is the "classic SIP" mode (no WebRTC media negotiation).
/// Suitable for hardware phones / IAX2 compatible deployments.
library;

import 'dart:async';

import 'package:sip_ua/sip_ua.dart';
import 'package:pbx_client_sample/core/utils/logger.dart';
import 'package:pbx_client_sample/domain/entities/call_entity.dart';
import 'package:pbx_client_sample/domain/entities/connection_entity.dart';
import 'package:pbx_client_sample/domain/repositories/call_repository.dart';
import 'package:pbx_client_sample/domain/repositories/connection_repository.dart';

/// Implements [ConnectionRepository] and [CallRepository] for classic SIP mode.
/// Uses the sip_ua package with a WebSocket transport pointed at plain ws:// or
/// the Asterisk HTTP server on port 8088 (non-TLS).
class SipService implements SipUaHelperListener, ConnectionRepository, CallRepository {
  final SIPUAHelper _helper = SIPUAHelper();

  final _registrationController =
      StreamController<RegistrationStatus>.broadcast();
  final _callController = StreamController<CallEntity>.broadcast();

  RegistrationStatus _status = RegistrationStatus.unregistered;
  final Map<String, Call> _activeCalls = {};

  SipService() {
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
    // In plain SIP mode, use ws:// (Asterisk http.conf port 8088 by default)
    settings.webSocketUrl = config.wssUri;
    settings.uri = 'sip:${config.username}@${config.host}';
    settings.authorizationUser = config.username;
    settings.password = config.password;
    settings.displayName = config.displayName;
    settings.userAgent = 'PBX-Client-Flutter/1.0';

    appLogger.i('[SipService] Connecting to ${config.wssUri}');
    _helper.start(settings);
  }

  @override
  Future<void> disconnect() async {
    _helper.stop();
  }

  // ── CallRepository ────────────────────────────────────────────────────────

  @override
  Stream<CallEntity> get callStream => _callController.stream;

  @override
  Future<CallEntity> makeCall(String destination) async {
    _helper.call(destination, voiceonly: true);
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
    _activeCalls[sessionId]?.answer(_helper.buildCallOptions(voiceonly: true));
  }

  @override
  Future<void> hangupCall(String sessionId) async {
    _activeCalls[sessionId]?.hangup();
  }

  @override
  Future<void> toggleMute(String sessionId, {required bool mute}) async {
    final call = _activeCalls[sessionId];
    mute ? call?.mute() : call?.unmute();
  }

  @override
  Future<void> toggleHold(String sessionId, {required bool hold}) async {
    final call = _activeCalls[sessionId];
    hold ? call?.hold() : call?.unhold();
  }

  @override
  Future<void> sendDtmf(String sessionId, String digit) async {
    _activeCalls[sessionId]?.sendDTMF(digit);
  }

  // ── SipUaHelperListener ───────────────────────────────────────────────────

  @override
  void registrationStateChanged(RegistrationState state) {
    final status = switch (state.state) {
      RegistrationStateEnum.REGISTERED => RegistrationStatus.registered,
      RegistrationStateEnum.UNREGISTERED => RegistrationStatus.unregistered,
      RegistrationStateEnum.REGISTRATION_FAILED => RegistrationStatus.failed,
      _ => RegistrationStatus.registering,
    };
    _status = status;
    _registrationController.add(status);
  }

  @override
  void callStateChanged(Call call, CallState2 callState) {
    _activeCalls[call.id] = call;
    // TODO: map to CallEntity and emit to _callController
  }

  @override
  void onNewMessage(SIPMessageRequest msg) {}

  @override
  void onNewNotify(Notify ntf) {}

  void dispose() {
    _registrationController.close();
    _callController.close();
  }
}
