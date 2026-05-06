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
