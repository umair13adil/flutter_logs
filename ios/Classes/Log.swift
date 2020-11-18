//
//  Logger+Finances.swift
//  FinanceKit
//
//  Created by Matthias Hochgatterer on 03.04.18.
//  Copyright © 2018 Matthias Hochgatterer. All rights reserved.
//
import Foundation

fileprivate let _fileManager = FileManager()
public var LogDirectoryName = "Logs"

public struct Logging {
    
    /// The list is sorted ascending by file creation date.
    ///
    /// - Returns: A list of file urls containing application logs.
    public static var fileURLs: [URL]?  {
        guard let logsDir = defaultLogsDirectoryURL()  else {
            return nil
        }
        if let urls = try? _fileManager.contentsOfDirectory(at: logsDir, includingPropertiesForKeys: [.creationDateKey], options: .skipsHiddenFiles) {
            return urls.sorted(by: {
                lhs, rhs in
                
                guard let lhsDate = (try? lhs.resourceValues(forKeys: [.creationDateKey]))?.creationDate, let rhsDate = (try? rhs.resourceValues(forKeys: [.creationDateKey]))?.creationDate else {
                    return true
                }
                
                return lhsDate > rhsDate
            })
        }
        
        return nil
    }
    
    public static func defaultLogsDirectoryURL() -> URL? {
        do {
            let dir = try _fileManager.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            var dirURL = dir.appendingPathComponent(LogDirectoryName)
            
            // Create directory if needed
            if !_fileManager.fileExists(atPath: dirURL.path) {
                try _fileManager.createDirectory(at: dirURL, withIntermediateDirectories: true, attributes: nil)
                
                // Exclude Logs directory from backups
                var values = URLResourceValues()
                values.isExcludedFromBackup = true
                try dirURL.setResourceValues(values)
            }
            return dirURL
        } catch let error as NSError {
            Swift.print("Could not find Application Support directory:", error.localizedDescription)
        }
        
        return nil
    }
}
