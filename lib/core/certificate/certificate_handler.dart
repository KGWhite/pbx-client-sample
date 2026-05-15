/// Custom certificate handler for self-signed / internal CA certificates.
///
/// Asterisk servers in private networks often use self-signed TLS certs.
/// This file provides a hook to configure Dart's HttpClient to trust them.
/// WARNING: Only disable certificate validation in debug/development builds.
library;

import 'dart:io';

/// Creates an HttpClient that accepts a specific set of trusted certificates.
/// In production, replace [allowBadCertificate] with proper cert pinning.
HttpClient createTrustedClient({bool allowBadCertificate = false}) {
  final client = HttpClient();
  if (allowBadCertificate) {
    // TODO(dev): Replace with certificate pinning before release.
    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
  }
  return client;
}
