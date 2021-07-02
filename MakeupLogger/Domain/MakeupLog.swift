//
//  MakeupLog.swift
//  MakeupLogger
//
//  Created by 齋藤健悟 on 2021/02/20.
//

import Foundation
import RealmSwift

enum DefaultFaceParts: String, CaseIterable {
    case eye
    case lip
    case cheek
    
    static var list: [FacePart] {
        let list = self.allCases.map { (type: DefaultFaceParts) -> FacePart in
            let part = FacePart()
            part.id = FacePartID()
            part.type = type.rawValue
            return part
        }
        return list
    }
}

class MakeupLog: Object {
    override init() {
        super.init()
    }
    
    static func make(id: MakeupLogID, title: String, body: String? = nil, imagePath: String) -> MakeupLog {
        let log = MakeupLog()
        log.id = id
        log.title = title
        log.body = body
        log.imagePath = imagePath
        let list = List<FacePart>()
        DefaultFaceParts.list.forEach {
            list.append($0)
        }
        log.partsList = list
        return log
    }
    
    @objc dynamic var id: MakeupLogID? = nil
    @objc dynamic var title: String = ""
    @objc dynamic var body: String? = nil
    @objc dynamic var imagePath: String = ""
    @objc dynamic var createAt = Date()
    var partsList: List<FacePart> = List<FacePart>()
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let log = object as? MakeupLog else {
            return false
        }
        return self.id == log.id
    }
}

class MakeupLogID: Object {
    @objc dynamic var id: String = UUID().uuidString
    
    override init() {
        super.init()
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let objectID = object as? MakeupLogID else {
            return false
        }
        return self.id == objectID.id
    }
    
    func folderName() -> String {
        "makeuplog"
    }
    
    func filename() -> String {
        id.description + ".png"
    }
}
