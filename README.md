<div align="center">

# 🌟 MeetKSA Customer Mobile Shell

**Production-grade hybrid mobile application for the MeetKSA SuiteKonnect customer platform.**

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Android](https://img.shields.io/badge/Android-API%2021+-3DDC84?style=for-the-badge&logo=android&logoColor=white)](https://developer.android.com)
[![iOS](https://img.shields.io/badge/iOS-13.0+-000000?style=for-the-badge&logo=apple&logoColor=white)](https://developer.apple.com)
[![Codemagic](https://img.shields.io/badge/Codemagic-CI%2FCD-F7931E?style=for-the-badge&logo=codemagic&logoColor=white)](https://codemagic.io)
[![Status](https://img.shields.io/badge/Status-Production%20Ready-brightgreen?style=for-the-badge)](#)

<p align="center">
  <a href="#-key-features">Features</a> •
  <a href="#-architecture">Architecture</a> •
  <a href="#-getting-started">Getting Started</a> •
  <a href="#-build--deployment">Build & Deployment</a> •
  <a href="#-ci--cd-automation">CI / CD</a> •
  <a href="#-permissions--security">Permissions</a>
</p>

---

</div>

## 📖 Overview

**MeetKSA Customer** is a Flutter-based native shell providing a reliable mobile experience for the **MeetKSA SuiteKonnect** web platform. It bridges web applications with native mobile OS capabilities — offering offline resilience, native hardware permission management, bi-directional JavaScript bridging, and native PDF printing/saving.

---

## ✨ Key Features

### 🖨️ Native Print & Save as PDF Engine
- **Direct System Print Integration**: Intercepts printable web documents (`/pdf/download`) and invokes Android `PrintManager` and iOS AirPrint/PrintDocumentAdapter directly.
- **1-Click Vector PDF Export**: Users can save high-resolution multi-page PDF documents directly to their device storage.
- **Bi-Directional JS Bridge**: Automatically catches `window.print()` triggers from web templates and routes them to native system dialogs.

### 🔐 Session & Cookie Synchronization
- **Native CookieManager Bridge**: Extracts and unifies `HttpOnly` and session cookies across all subdomains (`customer.meetksa`, `suitekonnect.com`) for persistent authentication.
- **Zero-Drop Navigation**: Seamless state transitions without unexpected logout redirects.

### 📶 Network Resilience & Offline Detection
- **Real-time Connectivity Engine**: Live network monitoring via `connectivity_plus`.
- **Smart Offline Screen**: Graceful fallback UI with retry mechanisms and cached resource handlers.
- **Auto-Recovery**: Automatically refreshes the active session when connectivity is restored.

### 🛡️ Native Permission Center
- **Dedicated Permission Center Screen**: User-friendly permission manager for Location, Camera, Photos/Files, and Push Notifications.
- **Granular Handling**: Just-in-time runtime requests with clear rationale dialogs.

### 🎨 Clean & Slim Navigation UI
- **Slim Glassmorphic Header**: Modern, non-intrusive toolbar with live connection badges.
- **Hardware Back Navigation**: Android hardware back button and iOS swipe gestures mapped to in-app WebView history.

---

## 🏗️ Architecture & Project Structure

The project follows a clean **Feature-First + Core Architecture** designed for maintainability and scalability:

```text
meetksa-customers/
├── .github/workflows/          # Automated GitHub Actions CI/CD workflows
│   └── build_ios.yml           # macOS Cloud Builder for iOS IPA & Android
├── android/                    # Native Android configurations & Kotlin bridge
│   └── app/src/main/kotlin/    # MainActivity.kt (Native Cookie & Print channels)
├── ios/                        # Native iOS configurations & Info.plist
│   └── Runner/Info.plist       # App Store permissions & bundle configurations
├── lib/
│   ├── app/                    # Application setup, router, & design theme
│   ├── config/                 # Multi-environment configs (prod, staging, dev)
│   ├── core/                   # Shared cross-cutting modules
│   │   ├── constants/          # App constants, URLs, strings, & assets
│   │   ├── errors/             # Standardized error handling & exceptions
│   │   ├── services/           # Native bridge, print, cookies, download, location
│   │   ├── utils/              # Validators, logging, & platform utilities
│   │   └── widgets/            # Reusable UI components & dialogs
│   ├── features/               # Domain-specific modules
│   │   ├── connectivity/       # Offline detection & network banners
│   │   ├── permissions/        # Permission center & runtime requests
│   │   ├── splash/             # Brand animation & startup initializers
│   │   └── webview/            # Controller, loading skeletons, & toolbar
│   └── main.dart               # Main entry point
├── build_ios.sh                # 1-Click macOS automated build script
├── codemagic.yaml              # Codemagic Cloud CI/CD configuration
└── pubspec.yaml                # Project metadata & dependencies
```

---

## 🚀 Getting Started

### Prerequisites
- **Flutter SDK**: `>= 3.0.0 < 4.0.0`
- **Dart SDK**: `>= 3.0.0`
- **Android Studio / VS Code** with Flutter & Dart extensions
- **Java JDK**: `17`

### Installation
1. **Clone the repository:**
   ```bash
   git clone https://github.com/your-org/meetksa-customers.git
   cd meetksa-customers
   ```

2. **Install Flutter packages:**
   ```bash
   flutter pub get
   ```

3. **Verify project integrity:**
   ```bash
   flutter analyze
   ```

4. **Run in debug mode:**
   ```bash
   flutter run
   ```

---

## 📦 Build & Deployment

### 🤖 Android Builds

| Target | Command | Output Location | Purpose |
| :--- | :--- | :--- | :--- |
| **Play Store Bundle** | `flutter build appbundle --release` | `build/app/outputs/bundle/release/app-release.aab` | Google Play Console Upload |
| **Release APK** | `flutter build apk --release` | `build/app/outputs/flutter-apk/app-release.apk` | Direct Device Testing |

### 🍎 iOS Builds

#### Method A: Direct Mac Build (Recommended)
Run the automated build script on any macOS machine:
```bash
chmod +x build_ios.sh
./build_ios.sh
```
*Output: `build/ios/ipa/meetksa_customer.ipa` & `build/ios/archive/Runner.xcarchive`*

#### Method B: Manual Xcode Archive
```bash
flutter clean && flutter pub get
cd ios && pod install && cd ..
flutter build ipa --release
```
Open `ios/Runner.xcworkspace` in Xcode ➔ **Window ➔ Organizer ➔ Distribute App**.

---

## ⚡ CI / CD Automation

### 1. Codemagic Cloud Builds ([`codemagic.yaml`](codemagic.yaml))
- Connect your Git repository to **[Codemagic.io](https://codemagic.io)**.
- Trigger `ios-release` workflow to compile iOS `.ipa` on cloud Apple Silicon Mac machines without needing local hardware.

### 2. GitHub Actions ([`.github/workflows/build_ios.yml`](.github/workflows/build_ios.yml))
- Automated CI pipeline runs on every push to `main` branch.
- Packages unsigned IPA and production Android release bundles automatically into downloadable artifacts.

---

## 🔒 Permissions & Security

| Permission | iOS Key (`Info.plist`) | Android Manifest | Rationale |
| :--- | :--- | :--- | :--- |
| 📍 **Location** | `NSLocationWhenInUseUsageDescription` | `ACCESS_FINE_LOCATION` | Geolocation verification for customer service requests |
| 📷 **Camera** | `NSCameraUsageDescription` | `CAMERA` | Scanning QR codes and capturing ticket issue photos |
| 📁 **Photos / Storage** | `NSPhotoLibraryUsageDescription` | `READ_MEDIA_IMAGES` | Uploading documents and maintenance attachments |
| 🔔 **Notifications** | Standard APNs / UNUserNotification | `POST_NOTIFICATIONS` | Order status alerts and service notifications |

---

## 👥 Authors & Maintainers

- **MeetKSA Development Team** — [MeetKSA Official Portal](https://meetksa.com)
- Maintained for **MeetKSA Customer Mobile Shell Ecosystem**.

---

<div align="center">
  <sub>Built with ❤️ using Flutter. Copyright © 2026 MeetKSA. All rights reserved.</sub>
</div>
