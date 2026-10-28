## 2.2.8+agp9.1
* Android: builds with Android Gradle Plugin 9 and built-in Kotlin (`android.builtInKotlin=true`), and still builds with AGP 8. Following Flutter's built-in Kotlin migration guide, the plugin no longer applies `kotlin-android` itself; AGP 9 provides Kotlin, and Flutter 3.44+ applies the Kotlin Gradle plugin when built-in Kotlin is off. This also removes Flutter's "plugins that apply Kotlin Gradle Plugin" warning
* Android: replaced `android.kotlinOptions` (not available with built-in Kotlin) with a top-level `kotlin { compilerOptions { jvmTarget = JVM_1_8 } }` block, so Kotlin still targets Java 8 to match `compileOptions`
* Android: bumped the plugin's Kotlin Gradle plugin version from 1.8.10 to 2.2.20 and removed the explicit `kotlin-stdlib-jdk7` dependency; the standard library is added automatically
* Android: added a consumer keep rule for WorkManager's Room database constructor. Under AGP 9's R8 strict full mode, the rule shipped with Room 2.5 no longer keeps it, so release builds crashed at startup
* Minimum versions are now Flutter 3.44 / Dart 3.12, which are required for Flutter to apply Kotlin to plugins
* Example: now depends on the plugin by path instead of from pub.dev, and uses Kotlin 2.2.20 (the minimum for Flutter 3.47) with a larger Gradle heap

## 2.2.8
* Fixed exporting logs a second time in the example app — it used a single static `Completer`, so later exports immediately returned the first export's (possibly deleted) zip path and the `logsExported` handler threw `Bad state: Future already completed`. A new `Completer` is now created for each export
* Fixed `type 'Null' is not a subtype of type 'String'` errors — every Dart method except `initLogs` now treats the native reply as nullable (`String?`)
* Android: `logThis`, `logToFile`, `printLogs`, `printFileLogForName`, `printFilteredLogs` and `clearLogs` now reply to the method call, so awaiting them no longer hangs
* iOS: methods not yet implemented on iOS (`initMQTT`, `setMetaInfo`, `exportFileLogForName`, `exportAllFileLogs`, `printFileLogForName`, `exportFilteredLogs`, `printFilteredLogs`) now reply with a "Not supported on iOS" message instead of never replying; unknown methods return `FlutterMethodNotImplemented`
* iOS: `logThis` and `logToFile` now reply when arguments are missing or the logs directory is not found; `clearLogs` and `printLogs` no longer reply more than once
* iOS: export failures now send `logsExported` with the error message, matching Android, so listeners waiting for an export are always notified

## 2.2.7
* Refactored `FlutterLogsPlugin` to modern Flutter plugin standards — all state (`channel`, `eventChannel`, `applicationContext`) moved from static `companion object` fields to instance fields, eliminating potential memory leaks when the engine is detached and re-attached
* Removed `@JvmStatic` annotations; `setUpPluginMethods` and `invokeChannelMethod` are now private instance methods, consistent with the `FlutterPlugin` embedding API contract
* Channels are explicitly nulled out in `onDetachedFromEngine` to prevent stale reference retention
* Removed unused imports (`Activity`, `PluginRegistry`)
* Simplified example `MainActivity` — removed redundant `onCreate` override; `FlutterActivity` handles initialization automatically

## 2.2.6
* Wrapped all Native→Dart `invokeMethod` calls in `Handler(Looper.getMainLooper()).post { }` inside the shared `invokeChannelMethod` helper — guarantees main-thread dispatch regardless of the thread the RxJava subscription delivers on, preventing potential `IllegalStateException` crashes on devices where the observable completes off the main thread

## 2.2.5
* Added `MethodChannel.Result` callback to all Native→Dart `invokeMethod` calls (`logsExported`, `logsPrinted`) via a shared `invokeChannelMethod` helper — delivery outcome (success, Dart-side error, or missing handler) is now logged to Logcat under the `FlutterLogsPlugin` tag, making it straightforward to diagnose cases where `setMethodCallHandler` was not registered before export was triggered

## 2.2.4
* Fixed runtime type error (`type 'Null' is not a subtype of type 'String'`) in `exportLogs` — `invokeMethod` return type is now correctly declared as nullable (`String?`) with a safe fallback, preventing crashes when the native side returns null

## 2.2.3
* Fixed missing `result.success()` reply in `exportLogs`, `exportFileLogForName`, `exportAllFileLogs`, and `exportFilteredLogs` handlers — the omission caused the Dart-side channel call to hang indefinitely, which could silently suppress the `logsExported` callback from ever reaching the client app
* Added diagnostic logging when the method channel is unexpectedly null during a log export

## 2.2.2
* Added Backpressure support for high-volume logging scenarios
* Added Redaction & Masking support for sensitive data (Email, Phone, Credit Card, JWT, IP, custom patterns)
* Added Search & Filter functionality for logs (exportFilteredLogs, printFilteredLogs)
* Added multiple MaskTypes: FULL_MASK, PARTIAL, HASH
* Added custom RedactionRule support with regex patterns
* Updated example app with comprehensive demos for all new features

## 2.2.1
* Updated sourceCompatibility & targetCompatibility to JavaVersion.VERSION_1_8

## 2.2.0
* Updated RxLogs version
* Added support for 'isEnabled' flag to disable logs writing completely

## 2.1.10
* Set min sdkVersion to 16

## 2.1.9
* Added support for Android SDK 33

## 2.1.8
* Fixed build issues from [PR #47]

## 2.1.7
* Added Support for Android Embedding v2
* Updated dependencies
* Fixes PR #28,async functions should return Future + format

## 2.1.6
* Added support for flutter 3 build

## 2.1.5
* Removed double logs printing
* Updated RxLogs versions

## 2.1.4
* Null Safety Added

## 2.1.3
* Fixed file write issue on iOS Release Builds

## 2.1.2
* Added support for logging in iOS apps

## 2.1.1

* Improved logs export flow
* Added example for exporting logs in example app

## 2.1.0

* Updated Error messages Format in case of Errors & Exception logs

## 2.0.6

* Updated PLogs library version
* Removed Runtime permissions for storage

## 0.0.1

* TODO: Describe initial release.
