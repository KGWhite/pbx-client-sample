/// Background service handler for keeping SIP registration alive.
///
/// On Android, this will be used to run a foreground service.
/// On iOS, the PushKit/VoIP push integration will handle wake-up.
library;

import 'package:pbx_client_sample/core/utils/logger.dart';

class BackgroundService {
  bool _running = false;

  /// Starts the background keepalive mechanism.
  Future<void> start() async {
    if (_running) return;
    _running = true;
    appLogger.i('[BackgroundService] Started');
    // TODO: integrate with flutter_background_service or similar package.
  }

  /// Stops the background service.
  Future<void> stop() async {
    _running = false;
    appLogger.i('[BackgroundService] Stopped');
  }

  bool get isRunning => _running;
}
