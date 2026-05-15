/// States for the CallBloc.
library;

import 'package:equatable/equatable.dart';
import 'package:pbx_client_sample/domain/entities/call_entity.dart';

abstract class CallState extends Equatable {
  const CallState();
  @override
  List<Object?> get props => [];
}

/// No active call.
class CallIdle extends CallState {
  const CallIdle();
}

/// Call is being set up (outgoing or incoming).
class CallInProgress extends CallState {
  final CallEntity call;
  const CallInProgress(this.call);
  @override
  List<Object?> get props => [call];
}

/// Call is active and connected.
class CallActive extends CallState {
  final CallEntity call;
  const CallActive(this.call);
  @override
  List<Object?> get props => [call];
}

/// Call has ended.
class CallTerminated extends CallState {
  final String reason;
  const CallTerminated({this.reason = ''});
  @override
  List<Object?> get props => [reason];
}

/// An error occurred during the call.
class CallError extends CallState {
  final String message;
  const CallError(this.message);
  @override
  List<Object?> get props => [message];
}
