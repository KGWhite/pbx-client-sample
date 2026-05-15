/// Domain entity representing a SIP/WebRTC call.
library;

import 'package:equatable/equatable.dart';

/// Represents the lifecycle state of a call.
enum CallState {
  idle,
  calling,       // Outgoing: ringing on remote side
  ringing,       // Incoming: ringing locally
  connected,
  holding,
  ended,
  failed,
}

/// Immutable entity describing a single call session.
class CallEntity extends Equatable {
  final String sessionId;
  final String remoteNumber;
  final String remoteDisplayName;
  final CallState state;
  final DateTime startTime;
  final DateTime? connectedTime;
  final DateTime? endTime;
  final bool isMuted;
  final bool isSpeakerOn;
  final bool isOnHold;

  const CallEntity({
    required this.sessionId,
    required this.remoteNumber,
    required this.remoteDisplayName,
    required this.state,
    required this.startTime,
    this.connectedTime,
    this.endTime,
    this.isMuted = false,
    this.isSpeakerOn = false,
    this.isOnHold = false,
  });

  CallEntity copyWith({
    CallState? state,
    DateTime? connectedTime,
    DateTime? endTime,
    bool? isMuted,
    bool? isSpeakerOn,
    bool? isOnHold,
  }) {
    return CallEntity(
      sessionId: sessionId,
      remoteNumber: remoteNumber,
      remoteDisplayName: remoteDisplayName,
      state: state ?? this.state,
      startTime: startTime,
      connectedTime: connectedTime ?? this.connectedTime,
      endTime: endTime ?? this.endTime,
      isMuted: isMuted ?? this.isMuted,
      isSpeakerOn: isSpeakerOn ?? this.isSpeakerOn,
      isOnHold: isOnHold ?? this.isOnHold,
    );
  }

  @override
  List<Object?> get props => [
        sessionId,
        remoteNumber,
        remoteDisplayName,
        state,
        startTime,
        connectedTime,
        endTime,
        isMuted,
        isSpeakerOn,
        isOnHold,
      ];
}
