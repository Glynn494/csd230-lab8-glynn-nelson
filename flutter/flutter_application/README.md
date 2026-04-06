# Bookstore Flutter App

Mobile client for the CSD230 Spring Boot bookstore backend.  
Built with Flutter + Material 3. Supports Android and iOS.

---

## Features

| Tab | What you can do |
|---|---|
| 📚 Books | Browse all books, search by title or author, add to cart |
| 📰 Magazines | Browse magazines, search by title, add to cart |
| 🖥️ Hardware | Tabbed view for CPUs, GPUs, RAM, and Drives — search by name or manufacturer, add to cart |
| 🛒 Cart | View all cart items with prices, remove items, see running total |

- JWT login / logout (token persisted across app restarts via `shared_preferences`)
- Pull-to-refresh on every list
- Dark mode support (follows system setting)

---

## Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) ≥ 3.0
- Android Studio or Xcode (for emulator/simulator)
- The Spring Boot backend running (default port **8080**)

---

## 1 — Configure the backend IP

Open `lib/constants.dart` and set `kBaseUrl` to match your setup:

```dart
// Android emulator (maps to host machine localhost)
const String kBaseUrl = 'http://10.0.2.2:8080/api/rest';

// Physical Android/iOS device on same Wi-Fi — replace with your machine's LAN IP:
// const String kBaseUrl = 'http://192.168.1.42:8080/api/rest';

// iOS Simulator
// const String kBaseUrl = 'http://localhost:8080/api/rest';
```

To find your machine's LAN IP:
- **Windows:** `ipconfig` → look for IPv4 Address under your Wi-Fi adapter
- **macOS/Linux:** `ifconfig` or `ip addr` → look for `inet` under `en0` / `wlan0`

---

## 2 — Start the backend

Make sure your Spring Boot server is running before launching the app:

```bash
# From the project root
./mvnw spring-boot:run          # macOS / Linux
mvnw.cmd spring-boot:run        # Windows
```

The server starts on `http://localhost:8080`.

---

## 3 — Install Flutter dependencies

```bash
cd flutter_app
flutter pub get
```

---

## 4 — Run the app

```bash
# List available devices
flutter devices

# Run on a specific device
flutter run -d emulator-5554       # Android emulator
flutter run -d iPhone              # iOS simulator
flutter run -d <your-device-id>    # Physical device
```

---

## Project structure

```
lib/
├── main.dart                  # Entry point, theme, auth gate
├── constants.dart             # ← BASE URL lives here
├── models/
│   ├── book.dart
│   ├── magazine.dart
│   ├── hardware.dart          # CPU, GPU, RAM, Drive (single model with productType)
│   └── cart.dart
├── services/
│   └── api_service.dart       # All HTTP calls + JWT token storage
├── screens/
│   ├── login_screen.dart
│   ├── main_screen.dart       # Bottom nav shell
│   ├── books_screen.dart
│   ├── magazines_screen.dart
│   ├── hardware_screen.dart   # Tabbed: CPUs / GPUs / RAM / Drives
│   └── cart_screen.dart
└── widgets/
    ├── product_tile.dart      # Reusable product list tile
    └── search_bar_field.dart  # Reusable search input
```

---

## Credentials (seeded by the backend)

| Username | Password | Role |
|---|---|---|
| `admin` | `admin` | Admin |
| `user` | `user` | Regular user |

---

## Physical device checklist

1. Set `kBaseUrl` to your machine's LAN IP (not `10.0.2.2`)
2. Android: add your LAN IP to `android/app/src/main/res/xml/network_security_config.xml`
3. iOS: add your LAN IP to the `NSExceptionDomains` block in `ios/Runner/Info.plist`
4. Make sure your phone and computer are on the **same Wi-Fi network**
5. If using a firewall, allow inbound connections on port 8080
