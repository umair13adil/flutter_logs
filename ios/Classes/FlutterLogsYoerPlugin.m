#import "FlutterLogsYoerPlugin.h"
#if __has_include(<flutter_logs_yoer/flutter_logs_yoer-Swift.h>)
#import <flutter_logs_yoer/flutter_logs_yoer-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flutter_logs_yoer-Swift.h"
#endif

@implementation FlutterLogsYoerPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterLogsYoerPlugin registerWithRegistrar:registrar];
}
@end
