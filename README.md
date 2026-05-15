# pbx-client-sample

A Flutter-based Asterisk soft client for Android and iOS, supporting both **WebRTC (WSS)** and **standard SIP** connection modes with native call integration via CallKit (iOS) and ConnectionService (Android).

---

## Project Overview

This application connects to an Asterisk PBX server and provides:

- **WebRTC Mode** – uses a Secure WebSocket (WSS) transport with `sip_ua` + `flutter_webrtc` for browser-compatible media negotiation.
- **Standard SIP Mode** – uses a plain WebSocket transport with `sip_ua`, suitable for environments that do not require WebRTC media negotiation.
- **Native Call UI** – `webtrit_callkeep` bridges iOS CallKit and Android ConnectionService so incoming calls appear as native phone calls.
- **Clean Architecture** – domain, data, and presentation layers are fully decoupled for long-term maintainability.

---

## Prerequisites

### Client Side

| Tool | Minimum Version |
|------|----------------|
| Flutter SDK | 3.22+ |
| Dart SDK | 3.3+ |
| Xcode (iOS) | 15+ |
| Android Studio | Hedgehog+ |

### Asterisk Server Side

| Component | Requirement |
|-----------|-------------|
| Asterisk | 18 LTS or 20+ |
| `res_http_websocket` | Enabled (for WebRTC/WSS) |
| `chan_pjsip` | Enabled and configured |
| TLS Certificate | Required for WSS mode (Let's Encrypt or self-signed) |
| `http.conf` | `enabled=yes`, `tlsenable=yes` (port 8089 for WSS) |
| `pjsip.conf` | WebRTC-compatible transport with `media_encryption=dtls` |

---

## Project Structure

```
lib/
├── core/                  # Shared utilities and constants
│   ├── constants/         # App-wide constants and storage keys
│   ├── certificate/       # Custom TLS/certificate handling
│   ├── network/           # Network status utilities
│   └── utils/             # Logger and helper functions
├── domain/                # Business logic (no Flutter dependencies)
│   ├── entities/          # CallEntity, ConnectionEntity
│   ├── repositories/      # Abstract repository interfaces
│   └── usecases/          # Single-purpose use cases
├── data/                  # Concrete implementations
│   ├── services/
│   │   ├── webrtc/        # WebRtcService (sip_ua over WSS)
│   │   └── sip/           # SipService (classic SIP mode)
│   ├── repositories/      # local datasource (shared_preferences)
│   └── models/            # JSON serializable data models
├── presentation/          # UI and state management
│   ├── blocs/
│   │   ├── call/          # CallBloc (events, states, bloc)
│   │   └── connection/    # ConnectionCubit
│   └── pages/
│       ├── dialpad/       # Dialpad page
│       ├── call/          # In-call screen
│       └── settings/      # Connection settings page
└── services/              # Platform-level services
    ├── callkeep/          # CallKit / ConnectionService adapter
    └── background/        # Background SIP keepalive service
```

---

## Installation & Development

### 1. Clone the repository

```bash
git clone <repo-url> pbx-client-sample
cd pbx-client-sample
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Run on Android

```bash
flutter run -d android
```

### 4. Run on iOS

```bash
cd ios && pod install && cd ..
flutter run -d ios
```

### 5. Run tests

```bash
flutter test
```

---

## Connection Configuration

### WebRTC (WSS) Mode

This mode uses a Secure WebSocket connection to Asterisk's built-in HTTP server.

| Field | Example Value | Notes |
|-------|---------------|-------|
| Host | `pbx.example.com` | Asterisk FQDN |
| Port | `8089` | `http.conf` TLS port |
| WSS Path | `/ws` | Defined in `http.conf` |
| Use TLS | `true` | Required for WSS |
| Username | `1001` | PJSIP extension number |
| Password | `secret` | PJSIP extension password |

**Asterisk `pjsip.conf` snippet for WebRTC:**

```ini
[transport-wss]
type=transport
protocol=wss
bind=0.0.0.0

[1001]
type=endpoint
transport=transport-wss
context=from-internal
auth=auth1001
aors=aor1001
media_encryption=dtls
dtls_auto_generate_cert=yes
webrtc=yes
```

### Standard SIP Mode

| Field | Example Value | Notes |
|-------|---------------|-------|
| Host | `pbx.example.com` | Asterisk FQDN |
| Port | `8088` | `http.conf` plain HTTP port |
| WSS Path | `/ws` | |
| Use TLS | `false` | Plain WebSocket |
| Username | `1001` | PJSIP extension |
| Password | `secret` | PJSIP extension password |

> **Note:** Even in "SIP mode" the `sip_ua` library still uses a WebSocket transport (ws:// or wss://) to communicate with Asterisk. The distinction is that media negotiation does **not** require WebRTC DTLS/SRTP in this mode.

---

## Roadmap

| Feature | Status |
|---------|--------|
| WebRTC (WSS) registration & calls | 🔨 In progress |
| Standard SIP mode | 🔨 In progress |
| CallKit / ConnectionService integration | 🔨 Stub ready |
| Dialpad with DTMF | 🔨 In progress |
| In-call screen (mute, hold, keypad) | 🔨 In progress |
| Connection settings persistence | 🔨 In progress |
| Push Notifications (APNs / FCM) | 📋 Planned |
| Call Recording | 📋 Planned |
| Video Call support | 📋 Planned |
| Call History / CDR | 📋 Planned |
| Transfer (Blind / Attended) | 📋 Planned |
| Conference (3-way) | 📋 Planned |
| Multiple SIP accounts | 📋 Planned |

---

## License

MIT
