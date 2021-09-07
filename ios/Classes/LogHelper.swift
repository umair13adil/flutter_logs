//
//  LogHelper.swift
//
//  Created by Umair Adil on 10/11/2020.
//

import Foundation
import ZIPFoundation

class LogHelper: NSObject {
    
    static var TAG = "LogHelper"
    
    //MARK: constants
    static let sharedInstance = LogHelper()
    
    static var logFilePath: String {
        return ""
    }
    
    static func initLogs(result: @escaping FlutterResult){
        print("initLogs")
        
    }
    
    static func logToFile(result: @escaping FlutterResult, logFileName:String, message:String,
                          overwrite:Bool, appendTimeStamp:Bool){
        let log = "{\(logFileName)} {\(message)} {\(overwrite)}"
        
        guard let dirURL = Logging.defaultLogsDirectoryURL() else {
            print("Logs directory not found")
            return
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "y-MM"
        
        let fileName = "\(logFileName)-\(dateFormatter.string(from: Date()))"
        let fileURL = dirURL.appendingPathComponent(fileName).appendingPathExtension("txt")
        let output = FileOutput(filePath: fileURL.path)
        Logger.sharedInstance.addOutput(output)
        Logger.sharedInstance.log(prefix() + ": " + log)
        result(log)
    }
    
    static func logThis(result: @escaping FlutterResult,
                        tag:String,
                        subTag:String,
                        logMessage:String,
                        level:String){
        let log = "{\(tag)} {\(subTag)} {\(logMessage)} {\(level)}"
        
        guard let dirURL = Logging.defaultLogsDirectoryURL() else {
            print("Logs directory not found")
            return
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "y-MM"
        
        let fileName = "Log-\(dateFormatter.string(from: Date()))"
        let fileURL = dirURL.appendingPathComponent(fileName).appendingPathExtension("txt")
        let output = FileOutput(filePath: fileURL.path)
        Logger.sharedInstance.addOutput(output)
        Logger.sharedInstance.log(prefix() + ": " + log)
        result(log)
    }
    
    static func logThis(result: @escaping FlutterResult,
                        tag:String,
                        subTag:String,
                        logMessage:String,
                        level:String,
                        exception:String){
        let log = "{\(tag)} {\(subTag)} {\(logMessage)} {\(level)}"
        guard let dirURL = Logging.defaultLogsDirectoryURL() else {
            print("Logs directory not found")
            return
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "y-MM"
        
        let fileName = "Log-\(dateFormatter.string(from: Date()))"
        let fileURL = dirURL.appendingPathComponent(fileName).appendingPathExtension("txt")
        let output = FileOutput(filePath: fileURL.path)
        Logger.sharedInstance.addOutput(output)
        Logger.sharedInstance.log(prefix() + ": " + log)
        result(log)
    }
    
    static func getFiles(result: @escaping FlutterResult,eventSink: FlutterEventSink?,channel : FlutterMethodChannel?){
        guard let files = Logging.fileURLs  else {
            result("{\(TAG)} {getFiles} {No Files found!} {\(getTimeStamp())}")
            return
        }
        
        if(!files.isEmpty){
            
            files.forEach { (fileURL) in
                print(fileURL.absoluteURL)
            }
            
            zipLogs(result: result, zipName: "logs",eventSink:eventSink, channel:channel)
        }else{
            result("{\(TAG)} {getFiles} {No Files found!} {\(getTimeStamp())}")
        }
    }
    
    static func printLogs(result: @escaping FlutterResult,eventSink: FlutterEventSink?,channel : FlutterMethodChannel?){
        
        guard let files = Logging.fileURLs  else {
            result("{\(TAG)} {printLogs} {No Files found!} {\(getTimeStamp())}")
            return
        }
        
        if(!files.isEmpty){
            
            files.forEach { (fileURL) in
                //reading
                do {
                    let text2 = try String(contentsOf: fileURL, encoding: .utf8)
                    result("{\(TAG)} {printLogs} {Printed: \(text2)} {\(getTimeStamp())}")
                    channel?.invokeMethod("logsPrinted", arguments: text2)
                }
                catch {
                    print(error)
                    result("{\(TAG)} {printLogs} {Unable to read file. \(fileURL)} {\(getTimeStamp())}")
                }
            }
        }else{
            result("{\(TAG)} {printLogs} {No Files found!} {\(getTimeStamp())}")
        }
    }
    
    static func clearLogs(result: @escaping FlutterResult){
        let documentsUrl = Logging.defaultLogsDirectoryURL()
        let fileManager = FileManager.default
        do {
            let directoryContents = try fileManager.contentsOfDirectory(at: documentsUrl!, includingPropertiesForKeys: nil)
            
            let files = directoryContents
            
            for url in files {
                print("{\(TAG)} {clearLogs} {Cleared: \(url.absoluteString) {\(getTimeStamp())}")
                try fileManager.removeItem(at: url)
            }
            
//            let outputPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask,true)
//
//            for url in outputPath {
//                let u = URL(fileURLWithPath: url)
//                print("{\(TAG)} {clearLogs} {Cleared: \(u) {\(getTimeStamp())}")
//                try fileManager.removeItem(at: u)
//            }
            
            result("{\(TAG)} {clearLogs} {Logs Cleared!)} {\(getTimeStamp())}")
        } catch {
            print(error)
            result("{\(TAG)} {clearLogs} {No Logs found! )} {\(getTimeStamp())}")
        }
    }
    
    static func getTimeStamp()->String{
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.string(from: date)
    }
    
    static var _dateFormatter: DateFormatter?
    static func dateFormatter() -> DateFormatter {
        if _dateFormatter == nil {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "y-MM-dd HH:mm:ss.SSS Z"
            _dateFormatter = dateFormatter
        }
        return _dateFormatter!
    }
    
    static func prefix() -> String {
        return dateFormatter().string(from: Date())
    }
    
    static func zipLogs(result: @escaping FlutterResult, zipName:String,eventSink: FlutterEventSink?,channel : FlutterMethodChannel?) {
        
        let  path = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask,true).first!
        
        guard var sourceURL = Logging.defaultLogsDirectoryURL()  else {
            print("{\(TAG)} {zipData} {Dir not found!} {\(getTimeStamp())}")
            result("{\(TAG)} {zipData} {Dir not found!} {\(getTimeStamp())}")
            return
        }
        
        let zipName = "\(zipName)_\(getTimeStamp()).zip"
        
        var destinationURL = URL(fileURLWithPath: path)
        destinationURL.appendPathComponent(zipName)
        
        do {
            let fm = FileManager.default
            let items = try fm.contentsOfDirectory(atPath: sourceURL.path)
            
            guard let archive = Archive(url: destinationURL, accessMode: .create) else  {
                print("Unable to create an Archive!")
                result("Unable to create an Archive!")
                return
            }
            
            for item in items {
                print("Adding to Zip: \(item)")
                sourceURL = sourceURL.appendingPathComponent("/\(item)")
                
                try archive.addEntry(with: sourceURL.lastPathComponent, relativeTo: sourceURL.deletingLastPathComponent(), compressionMethod: CompressionMethod.deflate)
                
                guard Archive(url: destinationURL, accessMode: .update) != nil else  {
                    print("Unable to update the Archive!")
                    result("Unable to update the Archive!")
                    return
                }
                
                sourceURL.deleteLastPathComponent()
            }
            
            print("{\(TAG)} {zipLogs} {Zip created: \(destinationURL.lastPathComponent)} {\(getTimeStamp())}")
            
            result(destinationURL.lastPathComponent)
            channel?.invokeMethod("logsExported", arguments: "\(destinationURL.lastPathComponent)")
        } catch {
            print("{\(TAG)} {zipLogs} {No Files found!} {\(getTimeStamp())}")
            result("{\(TAG)} {zipLogs} {No Files found!} {\(getTimeStamp())}")
        }
    }
}
