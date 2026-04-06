// ─────────────────────────────────────────────────────────────────────────────
// BASE URL CONFIGURATION
//
// Android emulator  →  use 10.0.2.2  (maps to host machine's localhost)
// Physical device   →  use your machine's LAN IP, e.g. 192.168.1.42
// iOS simulator     →  use localhost or 127.0.0.1
//
// The Spring Boot server runs on port 8080 by default.
// ─────────────────────────────────────────────────────────────────────────────
const String kBaseUrl = 'http://10.0.2.2:8080/api/rest';
