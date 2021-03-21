//
//  MakeupLog.swift
//  MakeupLogger
//
//  Created by 齋藤健悟 on 2021/02/20.
//

import Foundation
import UIKit

struct MakeupLog: Equatable, Hashable {
    struct ID: Hashable {
        private let header = "makeuplog"
        private let idNumber: Int
        private var id: String {
            header + "_" + idNumber.description
        }
        
        init(idNumber: Int) {
            self.idNumber = idNumber
        }
        
        func makeNextID() -> ID {
            ID(idNumber: self.idNumber + 1)
        }
    }
    let id: ID
    let title: String
    let image: UIImage
    var partsList: [FacePart]
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct FacePart: Equatable, Hashable {
    struct ID: Equatable, Hashable {
        private let header = "facepart"
        private let idNumber: Int
        private var id: String {
            header + "_" + idNumber.description
        }
        
        init(idNumber: Int) {
            self.idNumber = idNumber
        }
        
        func makeNextID() -> ID {
            ID(idNumber: self.idNumber + 1)
        }
    }
    
    let id: ID
    let type: String
    let image: UIImage
    var annotations: [FaceAnnotation]
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    func makeNextFaceAnnotationID() -> FaceAnnotation.FAID {
        if annotations.isEmpty {
            return FaceAnnotation.FAID()
        }
        return annotations.last!.id.makeNextAnnotationID()
    }
}
