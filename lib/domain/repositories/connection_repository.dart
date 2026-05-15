/// Abstract repository interface for SIP/WebRTC registration & connection.
library;

import 'package:pbx_client_sample/domain/entities/connection_entity.dart';

/// Registration status emitted from the connection stream.
enum RegistrationStatus {
  unregistered,
  registering,
  registered,
  failed,
}

abstract class ConnectionRepository {
  /// Connects and registers to the Asterisk server using [config].
  Future<void> connect(ConnectionEntity config);

  /// Unregisters and tears down the SIP stack.
  Future<void> disconnect();

  /// Stream of registration status changes.
  Stream<RegistrationStatus> get registrationStream;

  /// Current registration status (synchronous snapshot).
  RegistrationStatus get currentStatus;
}
