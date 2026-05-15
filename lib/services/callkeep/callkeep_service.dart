/// Callkeep integration service.
///
/// Wraps webtrit_callkeep to bridge native CallKit (iOS) and
/// ConnectionService (Android) with the app's call state machine.
library;

import 'package:pbx_client_sample/core/utils/logger.dart';

/// Provides a thin adapter around webtrit_callkeep for handling
/// system-level call events (answer, decline, end) and reporting
/// call state to the native dialer UI.
class CallkeepService {
  // TODO: inject webtrit_callkeep controller here once API is stable.

  /// Reports a new incoming call to the native UI.
  Future<void> reportIncomingCall({
    required String callId,
    required String callerName,
    required String callerNumber,
  }) async {
    appLogger.i('[CallkeepService] Incoming call: $callerName ($callerNumber)');
    // TODO: implement webtrit_callkeep.reportNewIncomingCall(...)
  }

  /// Notifies the system that a call has been connected.
  Future<void> reportCallConnected(String callId) async {
    appLogger.i('[CallkeepService] Call connected: $callId');
    // TODO: implement webtrit_callkeep.reportConnectedOutgoingCall(...)
  }

  /// Notifies the system that a call has ended.
  Future<void> reportCallEnded(String callId) async {
    appLogger.i('[CallkeepService] Call ended: $callId');
    // TODO: implement webtrit_callkeep.reportEndCall(...)
  }

  /// Starts an outgoing call in the native dialer.
  Future<void> startOutgoingCall({
    required String callId,
    required String handle,
  }) async {
    appLogger.i('[CallkeepService] Starting outgoing call to $handle');
    // TODO: implement webtrit_callkeep.startCall(...)
  }
}
