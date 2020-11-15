//
//  LogHelper.swift
//
//  Created by Umair Adil on 10/11/2020.
//

import Foundation
import SwiftLog

class LogHelper: NSObject {
    
    //MARK: constants
    static let sharedInstance = LogHelper()
    
    var logFilePath: String {
        return Log.logger.currentPath
    }
    
    static func initLogs(){
        //Set the name of the log files
        Log.logger.name = "test" //default is "logfile"
        
        //Set the max size of each log file. Value is in KB
        Log.logger.maxFileSize = 2048 //default is 1024
        
        //Set the max number of logs files that will be kept
        Log.logger.maxFileCount = 8 //default is 4
        
        //Set the directory in which the logs files will be written
        Log.logger.directory = "/Library/somefolder" //default is the standard logging directory for each platform.
        
        //Set whether or not writing to the log also prints to the console
        Log.logger.printToConsole = true //default is true
    }
    
    static func log(message:String){
        print(message)
        logw("write to the log!")
    }
    
    static func getFiles(){
        do {
            let files = try FileManager.default.contentsOfDirectory(atPath: Log.logger.directory)
            for fileName in files {
                let path = "\(Log.logger.directory)/\(fileName)"
                print(path)
            }
        } catch {
            //does nothing, because the file might not be there
        }
    }
    
    static func clearLogs(){
        do {
            let files = try FileManager.default.contentsOfDirectory(atPath: Log.logger.directory)
            for fileName in files {
                let path = "\(Log.logger.directory)/\(fileName)"
                try FileManager.default.removeItem(atPath: path)
            }
        } catch {
            //does nothing, because the file might not be there
        }
    }
}
