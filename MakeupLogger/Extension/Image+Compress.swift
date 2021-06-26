//
//  Image+Compress.swift
//  MakeupLogger
//
//  Created by 齋藤健悟 on 2021/06/26.
//

import Foundation
import UIKit

extension UIImage {
    func compressData() -> Data? {
        guard let count = self.pngData()?.count else {
            return nil
        }
        if count > 1 * 1024 * 1024 {
            return self.jpegData(compressionQuality: 0.5)
        }
        return self.pngData()
    }
}
