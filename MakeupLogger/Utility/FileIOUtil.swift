//
//  FileIOUtil.swift
//  MakeupLogger
//
//  Created by 齋藤健悟 on 2021/06/26.
//

import Foundation

enum FileIOUtil {
    static func saveToDocument(folderName: String, fileName: String, data: Data) throws {
        let folderURL = try FileManager.default.url(for: .documentDirectory,
                                                    in: .userDomainMask,
                                                    appropriateFor: nil,
                                                    create: true)
            .appendingPathComponent(folderName)
        let url = folderURL.appendingPathComponent(fileName)
        do {
            try data.write(to: url)
        } catch {
            try FileManager.default.createDirectory(at: folderURL,
                                                    withIntermediateDirectories: true,
                                                    attributes: nil)
            try data.write(to: url)
        }
    }
    
    static func getImageDataFromDocument(path: String) -> Data? {
        guard let url = try? FileManager.default.url(for: .documentDirectory,
                                                       in: .userDomainMask,
                                                       appropriateFor: nil,
                                                       create: false)
            .appendingPathComponent(path) else {
            return nil
        }
        print(url.path)
        return FileManager.default.contents(atPath: url.path)
    }
}
