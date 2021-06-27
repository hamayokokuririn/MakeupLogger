//
//  FacePart.swift
//  MakeupLogger
//
//  Created by 齋藤健悟 on 2021/05/17.
//

import Foundation
import RealmSwift

class FacePart: Object {
    override init() {
        super.init()
    }
    
    static func make(id: FacePartID, type: String, imagePath: String, annotations: [FaceAnnotationObject]) -> FacePart {
        let part = FacePart()
        part.id = id
        part.type = type
        part.imagePath = imagePath
        let list = List<FaceAnnotationObject>()
        annotations.forEach { list.append($0)}
        part.annotations = list
        return part
    }
    
    @objc dynamic var id: FacePartID? = nil
    @objc dynamic var type: String = ""
    @objc dynamic var imagePath: String = ""
    var annotations: List<FaceAnnotationObject> = List<FaceAnnotationObject>()
    
    static func == (lhs: FacePart, rhs: FacePart) -> Bool {
        return lhs.id == rhs.id
    }
    
    func makeNextFaceAnnotationID() -> FaceAnnotationID {
        if annotations.isEmpty {
            return FaceAnnotationID()
        }
        return annotations.last!.id.makeNextAnnotationID()
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let part = object as? FacePart else {
            return false
        }
        return self.id == part.id
    }
}

class FacePartID: Object {
    @objc dynamic var id: Int = 0
    override init() {
        super.init()
    }
    
    func makeNextID() -> FacePartID {
        let id = FacePartID()
        id.id = self.id + 1
        return id
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let id = object as? FacePartID else {
            return false
        }
        return self.id == id.id
    }
    
    var folderName: String {
        "facepart"
    }
    
    var fileName: String {
        id.description + ".png"
    }
}
