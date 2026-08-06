# App Debug WebView – Monorepo

A **Turborepo** monorepo containing two mobile apps for debugging WebViews via [Chrome DevTools Remote Debugging](http://developer.chrome.com/docs/devtools/remote-debugging/webviews).

## Apps

| App | Framework | Path |
|-----|-----------|------|
| WebView Debug RN | React Native | `apps/WebViewDebugRN` |
| WebView Debug Flutter | Flutter | `apps/webview-debug-flutter` |

## Features

Each app provides:
1. **Config Screen** – Set the URL to load, configure WebView settings (JavaScript, DOM storage, mixed content, user-agent, remote debugging toggle).
2. **Preview Screen** – Renders the URL in a WebView with navigation controls (back, forward, reload) and a debug hint banner.

Remote WebView debugging is enabled so that you can inspect content in Chrome DevTools:

- **Android**: open `chrome://inspect` in Chrome on your desktop while the device/emulator is connected.
- **iOS**: use Safari → Develop menu while connected to a Mac.

## Structure

```
.
├── apps/
│   ├── WebViewDebugRN/        # React Native app
│   └── webview-debug-flutter/ # Flutter app
├── turbo.json
└── package.json
```

## Getting Started

### Prerequisites

- Node.js ≥ 22
- React Native environment (Android SDK / Xcode)
- Flutter SDK ≥ 3.0

### Install (monorepo root)

```bash
npm install
```

### React Native App

```bash
cd apps/WebViewDebugRN
npm install
# Android
npx react-native run-android
# iOS
npx react-native run-ios
```

### Flutter App

```bash
cd apps/webview-debug-flutter
flutter pub get
# Android
flutter run
# iOS
flutter run -d <ios-device>
```

## WebView Remote Debugging Setup

### Android

1. Enable **Developer Options** and **USB Debugging** on the device.
2. Connect via USB or use an emulator.
3. In the app, ensure **Remote Debugging Enabled** is toggled on.
4. Open `chrome://inspect` in a desktop Chrome browser.
5. Click **inspect** next to your WebView.

### iOS

1. On the device: **Settings → Safari → Advanced → Web Inspector** → ON.
2. Connect to a Mac.
3. Open **Safari → Develop → [device name]** to find the WebView.

## Permissions

### Android (`android:debuggable="true"`, `android:usesCleartextTraffic="true"`)

- `INTERNET` – required to load URLs.
- `ACCESS_NETWORK_STATE` – check connectivity.
- `usesCleartextTraffic` – allows `http://` URLs during debugging.
- `debuggable` – enables Chrome DevTools remote inspection.

### iOS (`NSAllowsArbitraryLoads: true`)

- `NSCameraUsageDescription` – web pages requesting camera.
- `NSMicrophoneUsageDescription` – web pages requesting microphone.
- `NSLocationWhenInUseUsageDescription` – web pages requesting location.
- `NSAllowsArbitraryLoads` – allows loading any URL scheme during development.
