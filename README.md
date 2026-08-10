# App Debug WebView – Monorepo

A **Turborepo** monorepo containing two mobile apps for debugging WebViews via [Chrome DevTools Remote Debugging](http://developer.chrome.com/docs/devtools/remote-debugging/webviews).

## Apps

| App                   | Framework    | Path                         |
| --------------------- | ------------ | ---------------------------- |
| WebView Debug RN      | React Native | `apps/WebViewDebugRN`        |
| WebView Debug Flutter | Flutter      | `apps/webview-debug-flutter` |

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

### Common tools

Install these tools before setting up either app:

- [Git](https://git-scm.com/)
- Node.js **22.11.0 or newer** and npm (required by the React Native app and the monorepo tooling)
- A physical device with developer mode enabled, or an Android/iOS simulator

Install the JavaScript dependencies once from the monorepo root. Dependencies for the React Native workspace are hoisted to the root `node_modules` directory.

```bash
npm ci
```

Use `npm install` instead when intentionally updating dependencies or when no lockfile is available.

## React Native Environment

The React Native app uses React Native 0.86.2.

### Android setup

1. Install [Android Studio](https://developer.android.com/studio) with:
   - Android SDK Platform 36
   - Android SDK Build-Tools 36.0.0
   - Android SDK Command-line Tools
   - Android Emulator
   - NDK 27.1.12297006
2. Install or select JDK 17. Android Studio's bundled JDK can be used.
3. Set `ANDROID_HOME` to the Android SDK directory and add `platform-tools` to `PATH`.

Example for Windows PowerShell (adjust the SDK path for your account):

```powershell
[Environment]::SetEnvironmentVariable("ANDROID_HOME", "$env:LOCALAPPDATA\Android\Sdk", "User")
[Environment]::SetEnvironmentVariable("Path", [Environment]::GetEnvironmentVariable("Path", "User") + ";$env:LOCALAPPDATA\Android\Sdk\platform-tools", "User")
```

Restart the terminal after changing environment variables, then verify the device or emulator:

```bash
adb devices
```

### iOS setup

iOS development and builds require macOS.

1. Install the latest stable Xcode and Xcode Command Line Tools.
2. Open Xcode once, accept the license, and install an iOS Simulator runtime.
3. Install Ruby Bundler; the repository `Gemfile` manages CocoaPods.
4. Install pods from the React Native app:

```bash
cd apps/WebViewDebugRN
bundle install
cd ios
bundle exec pod install
cd ..
```

Run the pod commands again after native dependencies change.

### Run the React Native source

Start Metro from the React Native app directory:

```bash
cd apps/WebViewDebugRN
npm start
```

Keep Metro running. In another terminal, launch the target platform:

```bash
cd apps/WebViewDebugRN

# Android device or emulator
npm run android

# iOS Simulator (macOS only)
npm run ios
```

### Build the React Native app

Build Android artifacts from `apps/WebViewDebugRN/android`:

```powershell
# Windows: release APK
.\gradlew.bat assembleRelease

# Windows: release Android App Bundle
.\gradlew.bat bundleRelease
```

```bash
# macOS/Linux: release APK
./gradlew assembleRelease

# macOS/Linux: release Android App Bundle
./gradlew bundleRelease
```

Artifacts are generated under:

- APK: `apps/WebViewDebugRN/android/app/build/outputs/apk/release/`
- AAB: `apps/WebViewDebugRN/android/app/build/outputs/bundle/release/`

The current React Native release build uses the debug keystore and is suitable only for local/internal testing. Configure a private release keystore before distributing the app.

For iOS, open `apps/WebViewDebugRN/ios/WebViewDebugRN.xcworkspace` in Xcode, select a signing team and a generic iOS device, then choose **Product → Archive**. Export the archive from Xcode Organizer to produce a signed `.ipa`.

## Flutter Environment

The Flutter app requires Flutter with Dart SDK **3.x** (`>=3.0.0 <4.0.0`).

### Android setup

1. Install the stable [Flutter SDK](https://docs.flutter.dev/get-started/install) and add its `bin` directory to `PATH`.
2. Install Android Studio, Android SDK Command-line Tools, an Android SDK platform, and an emulator.
3. Use JDK 17, as required by this app's Android Gradle configuration.
4. Accept Android licenses and inspect the local toolchain:

```bash
flutter doctor
flutter doctor --android-licenses
```

Resolve all relevant issues reported by `flutter doctor` before running the app.

### iOS setup

iOS development and builds require macOS. Install Flutter, Xcode, Xcode Command Line Tools, and CocoaPods, then run:

```bash
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch
flutter doctor
```

The Flutter iOS target requires iOS 12.0 or newer. A valid Apple signing team is required for physical-device and IPA builds.

### Run the Flutter source

```bash
cd apps/webview-debug-flutter
flutter pub get
flutter devices

# Run on an interactive device selection
flutter run

# Or target a specific device returned by flutter devices
flutter run -d <device-id>
```

### Build the Flutter app

Release builds are also triggered automatically for Git tags that include `flutter-release` (for example `v1.2.3-flutter-release`). The CI workflow builds the Flutter app, runs analysis and tests, and uploads release APK and App Bundle artifacts.

Run build commands from `apps/webview-debug-flutter`:

```bash
# Android release APK
flutter build apk --release

# Android release Android App Bundle
flutter build appbundle --release

# iOS release app (macOS only)
flutter build ios --release

# Signed IPA (macOS only; requires signing configuration)
flutter build ipa --release
```

Artifacts are generated under:

- APK: `apps/webview-debug-flutter/build/app/outputs/flutter-apk/`
- AAB: `apps/webview-debug-flutter/build/app/outputs/bundle/release/`
- iOS app/archive/IPA: `apps/webview-debug-flutter/build/ios/`

The Flutter Android release configuration currently uses debug signing. Configure a private release keystore before publishing to an app store.

## Validation

Run the checks for the app you changed.

### React Native

```bash
cd apps/WebViewDebugRN
npm run lint
npx tsc --noEmit
npm test -- --runInBand
```

### Flutter

```bash
cd apps/webview-debug-flutter
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
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
