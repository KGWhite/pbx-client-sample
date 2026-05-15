/// Persists and retrieves connection configuration using shared_preferences.
library;

import 'package:shared_preferences/shared_preferences.dart';
import 'package:pbx_client_sample/core/constants/app_constants.dart';
import 'package:pbx_client_sample/domain/entities/connection_entity.dart';

/// Data-layer implementation of local connection config storage.
class ConnectionLocalDataSource {
  final SharedPreferences _prefs;

  ConnectionLocalDataSource(this._prefs);

  /// Saves [config] to local storage.
  Future<void> saveConfig(ConnectionEntity config) async {
    await Future.wait([
      _prefs.setString(AppConstants.kSipHost, config.host),
      _prefs.setInt(AppConstants.kSipPort, config.port),
      _prefs.setString(AppConstants.kSipUsername, config.username),
      _prefs.setString(AppConstants.kSipPassword, config.password),
      _prefs.setString(AppConstants.kSipDisplayName, config.displayName),
      _prefs.setString(
        AppConstants.kConnectionMode,
        config.mode == ConnectionMode.webrtc
            ? AppConstants.kModeWebRtc
            : AppConstants.kModeSip,
      ),
      _prefs.setString(AppConstants.kWssPath, config.wssPath),
      _prefs.setBool(AppConstants.kUseTls, config.useTls),
    ]);
  }

  /// Loads saved config from local storage. Returns null if no config saved.
  ConnectionEntity? loadConfig() {
    final host = _prefs.getString(AppConstants.kSipHost);
    if (host == null) return null;

    final modeStr = _prefs.getString(AppConstants.kConnectionMode) ??
        AppConstants.kModeWebRtc;

    return ConnectionEntity(
      host: host,
      port: _prefs.getInt(AppConstants.kSipPort) ?? AppConstants.kDefaultSipPort,
      username: _prefs.getString(AppConstants.kSipUsername) ?? '',
      password: _prefs.getString(AppConstants.kSipPassword) ?? '',
      displayName: _prefs.getString(AppConstants.kSipDisplayName) ?? '',
      mode: modeStr == AppConstants.kModeWebRtc
          ? ConnectionMode.webrtc
          : ConnectionMode.sip,
      wssPath: _prefs.getString(AppConstants.kWssPath) ?? AppConstants.kDefaultWssPath,
      useTls: _prefs.getBool(AppConstants.kUseTls) ?? true,
    );
  }
}
