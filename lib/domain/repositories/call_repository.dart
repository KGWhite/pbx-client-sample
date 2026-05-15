/// Abstract repository interface for call operations.
///
/// Concrete implementations live in lib/data/repositories/.
library;

import 'package:pbx_client_sample/domain/entities/call_entity.dart';

abstract class CallRepository {
  /// Initiates an outgoing call to [destination].
  Future<CallEntity> makeCall(String destination);

  /// Answers an incoming call identified by [sessionId].
  Future<void> answerCall(String sessionId);

  /// Hangs up the call identified by [sessionId].
  Future<void> hangupCall(String sessionId);

  /// Toggles mute state for [sessionId].
  Future<void> toggleMute(String sessionId, {required bool mute});

  /// Toggles hold state for [sessionId].
  Future<void> toggleHold(String sessionId, {required bool hold});

  /// Sends DTMF tone [digit] for [sessionId].
  Future<void> sendDtmf(String sessionId, String digit);

  /// Stream of call state changes for active/incoming calls.
  Stream<CallEntity> get callStream;
}
