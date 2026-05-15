/// Use-case: make an outgoing call.
library;

import 'package:pbx_client_sample/domain/entities/call_entity.dart';
import 'package:pbx_client_sample/domain/repositories/call_repository.dart';

class MakeCallUseCase {
  final CallRepository _repository;

  MakeCallUseCase(this._repository);

  Future<CallEntity> call(String destination) =>
      _repository.makeCall(destination);
}
