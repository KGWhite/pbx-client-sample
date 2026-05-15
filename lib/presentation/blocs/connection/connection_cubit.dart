/// Cubit for managing SIP/WebRTC registration state.
library;

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pbx_client_sample/domain/entities/connection_entity.dart';
import 'package:pbx_client_sample/domain/repositories/connection_repository.dart';

export 'package:pbx_client_sample/domain/repositories/connection_repository.dart'
    show RegistrationStatus;

class ConnectionCubit extends Cubit<RegistrationStatus> {
  final ConnectionRepository _repository;
  StreamSubscription<RegistrationStatus>? _subscription;

  ConnectionCubit({required ConnectionRepository repository})
      : _repository = repository,
        super(RegistrationStatus.unregistered) {
    _subscription = _repository.registrationStream.listen(emit);
  }

  /// Connects to Asterisk using the provided [config].
  Future<void> connect(ConnectionEntity config) async {
    emit(RegistrationStatus.registering);
    await _repository.connect(config);
  }

  /// Disconnects from Asterisk.
  Future<void> disconnect() async {
    await _repository.disconnect();
    emit(RegistrationStatus.unregistered);
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
