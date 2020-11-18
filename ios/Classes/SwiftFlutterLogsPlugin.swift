import Flutter
import UIKit

public class SwiftFlutterLogsPlugin: NSObject, FlutterPlugin {
    
    var eventSink: FlutterEventSink?
    static var channel : FlutterMethodChannel?
    
    func setEventSink(eventSink: FlutterEventSink?) {
        self.eventSink = eventSink
    }
    
    static func setChannel(mChannel: FlutterMethodChannel?) {
        channel = mChannel
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_logs", binaryMessenger: registrar.messenger())
        
        setChannel(mChannel:channel)
        
        let instance = SwiftFlutterLogsPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        
        let eventChannel = FlutterEventChannel(name: "flutter_logs_plugin_stream", binaryMessenger: registrar.messenger())
        
        let eventHandler = EventsStreamHandler(instance:instance, channel: channel, registrar: registrar)
        eventChannel.setStreamHandler(eventHandler)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        
        
        if call.method == "initLogs" {
            LogHelper.initLogs(result:result)
            result("Logs Configuration added.")
        }else if call.method == "logThis" {
            guard let args = call.arguments else {
                return
            }
            if let myArgs = args as? [String: Any],
               let tag = myArgs["tag"] as? String,
               let subTag = myArgs["subTag"] as? String,
               let logMessage = myArgs["logMessage"] as? String,
               let level = myArgs["level"] as? String,
               let exception = myArgs["e"] as? String
            {
                LogHelper.logThis(result:result,tag:tag, subTag:subTag,logMessage:logMessage,level:level,exception:exception)
            }else if let myArgs = args as? [String: Any],
                     let tag = myArgs["tag"] as? String,
                     let subTag = myArgs["subTag"] as? String,
                     let logMessage = myArgs["logMessage"] as? String,
                     let level = myArgs["level"] as? String
            {
                LogHelper.logThis(result:result,tag:tag, subTag:subTag,logMessage:logMessage,level:level)
            } else {
                result("iOS could not extract flutter arguments in method: (logThis)")
            }
        }else if call.method == "logToFile" {
            guard let args = call.arguments else {
                return
            }
            if let myArgs = args as? [String: Any],
               let logFileName = myArgs["logFileName"] as? String,
               let overwrite = myArgs["overwrite"] as? Bool,
               let logMessage = myArgs["logMessage"] as? String,
               let appendTimeStamp = myArgs["appendTimeStamp"] as? Bool
            {
                LogHelper.logToFile(result:result,logFileName:logFileName, message: logMessage,overwrite:overwrite,appendTimeStamp:appendTimeStamp)
            } else {
                result("iOS could not extract flutter arguments in method: (logToFile)")
            }
        }else if call.method == "exportLogs" {
            LogHelper.getFiles(result:result,eventSink:eventSink, channel:SwiftFlutterLogsPlugin.channel)
        }else if call.method == "exportFileLogForName" {
            
        }else if call.method == "clearLogs" {
            LogHelper.clearLogs(result:result)
            result("Logs are cleared.")
        }else if call.method == "printLogs" {
            LogHelper.printLogs(result:result,eventSink:eventSink, channel:SwiftFlutterLogsPlugin.channel)
        }
    }
}

class EventsStreamHandler: NSObject, FlutterStreamHandler {
    
    private var eventSink: FlutterEventSink?
    
    private var fChannel:FlutterMethodChannel
    private var fRegistrar: FlutterPluginRegistrar?
    var instance: SwiftFlutterLogsPlugin?
    
    init(instance: SwiftFlutterLogsPlugin?, channel:FlutterMethodChannel,registrar: FlutterPluginRegistrar) {
        self.instance = instance
        self.fChannel = channel
        self.fRegistrar = registrar
    }
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        eventSink = events
        instance?.setEventSink(eventSink: eventSink)
        fRegistrar?.addMethodCallDelegate(instance!, channel: fChannel)
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil
        return nil
    }
}
