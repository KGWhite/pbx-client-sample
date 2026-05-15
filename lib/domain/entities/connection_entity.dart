/// Domain entity representing SIP account connection configuration.
library;

import 'package:equatable/equatable.dart';

/// Supported connection transport modes.
enum ConnectionMode { webrtc, sip }

/// Immutable entity holding all parameters needed to register with Asterisk.
class ConnectionEntity extends Equatable {
  final String host;
  final int port;
  final String username;
  final String password;
  final String displayName;
  final ConnectionMode mode;

  // WebRTC / WSS specific fields
  final String wssPath;
  final bool useTls;

  const ConnectionEntity({
    required this.host,
    required this.port,
    required this.username,
    required this.password,
    required this.displayName,
    required this.mode,
    this.wssPath = '/ws',
    this.useTls = true,
  });

  /// Builds the WebSocket URI for WSS mode.
  String get wssUri {
    final scheme = useTls ? 'wss' : 'ws';
    return '$scheme://$host:$port$wssPath';
  }

  /// Builds the SIP registrar URI.
  String get registrarUri => 'sip:$host:$port';

  ConnectionEntity copyWith({
    String? host,
    int? port,
    String? username,
    String? password,
    String? displayName,
    ConnectionMode? mode,
    String? wssPath,
    bool? useTls,
  }) {
    return ConnectionEntity(
      host: host ?? this.host,
      port: port ?? this.port,
      username: username ?? this.username,
      password: password ?? this.password,
      displayName: displayName ?? this.displayName,
      mode: mode ?? this.mode,
      wssPath: wssPath ?? this.wssPath,
      useTls: useTls ?? this.useTls,
    );
  }

  @override
  List<Object?> get props =>
      [host, port, username, password, displayName, mode, wssPath, useTls];
}
