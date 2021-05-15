//
//  MakeupLog.swift
//  MakeupLogger
//
//  Created by 齋藤健悟 on 2021/02/20.
//

import Foundation
import UIKit
import RealmSwift

class MakeupLog: Object {
    override init() {
        super.init()
    }
    
    static func make(id: MakeupLogID, title: String, body: String? = nil, image: Data, partsList: [FacePart]) -> MakeupLog {
        let log = MakeupLog()
        log.id = id
        log.title = title
        log.body = body
        log.image = image
        let list = List<FacePart>()
        partsList.forEach {
            list.append($0)
        }
        log.partsList = list
        return log
    }
    
    @objc dynamic var id: MakeupLogID? = nil
    @objc dynamic var title: String = ""
    @objc dynamic var body: String? = nil
    @objc dynamic var image: Data? = nil
    var partsList: List<FacePart> = List<FacePart>()
    
}

class MakeupLogID: Object {
    @objc dynamic var id: Int
    
    override init() {
        self.id = 0
        super.init()
    }
    
    convenience init(id: Int) {
        self.init()
        self.id = id
    }
    
    func makeNextID() -> MakeupLogID {
        MakeupLogID(id: self.id + 1)
    }
}

class FacePart: Object {
    override init() {
        super.init()
    }
    
    static func make(id: FacePartID, type: String, image: Data, annotations: [FaceAnnotation]) -> FacePart {
        let part = FacePart()
        part.id = id
        part.type = type
        part.image = image
        let list = List<FaceAnnotation>()
        annotations.forEach { list.append($0)}
        part.annotations = list
        return part
    }
    
    @objc dynamic var id: FacePartID? = nil
    @objc dynamic var type: String = ""
    @objc dynamic var image: Data? = nil
    var annotations: List<FaceAnnotation> = List<FaceAnnotation>()
    
    static func == (lhs: FacePart, rhs: FacePart) -> Bool {
        return lhs.id == rhs.id
    }
    
    func makeNextFaceAnnotationID() -> FaceAnnotationID {
        if annotations.isEmpty {
            return FaceAnnotationID()
        }
        return annotations.last!.id!.makeNextAnnotationID()
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
}
