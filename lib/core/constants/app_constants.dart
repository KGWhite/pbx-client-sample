/// Application-wide constants for SIP/WebRTC configuration.
library;

class AppConstants {
  AppConstants._();

  // ── Storage Keys ─────────────────────────────────────────────────────────
  static const String kSipHost = 'sip_host';
  static const String kSipPort = 'sip_port';
  static const String kSipUsername = 'sip_username';
  static const String kSipPassword = 'sip_password';
  static const String kSipDisplayName = 'sip_display_name';
  static const String kConnectionMode = 'connection_mode'; // 'webrtc' | 'sip'
  static const String kWssPath = 'wss_path';
  static const String kUseTls = 'use_tls';

  // ── Default Values ────────────────────────────────────────────────────────
  static const int kDefaultSipPort = 5060;
  static const int kDefaultWssPort = 8089;
  static const String kDefaultWssPath = '/ws';
  static const int kCallTimeoutSeconds = 60;

  // ── Connection Modes ──────────────────────────────────────────────────────
  static const String kModeWebRtc = 'webrtc';
  static const String kModeSip = 'sip';
}
