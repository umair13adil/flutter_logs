#import "FlutterLogsPlugin.h"
#if __has_include(<flutter_logs/flutter_logs-Swift.h>)
#import <flutter_logs/flutter_logs-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flutter_logs-Swift.h"
#endif

@implementation FlutterLogsPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterLogsPlugin registerWithRegistrar:registrar];
}
@end
