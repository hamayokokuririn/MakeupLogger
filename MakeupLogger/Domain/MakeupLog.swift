//
//  MakeupLog.swift
//  MakeupLogger
//
//  Created by 齋藤健悟 on 2021/02/20.
//

import Foundation
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
        log.imagePath = image
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
    @objc dynamic var imagePath: Data? = nil
    var partsList: List<FacePart> = List<FacePart>()
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let log = object as? MakeupLog else {
            return false
        }
        return self.id == log.id
    }
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
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let objectID = object as? MakeupLogID else {
            return false
        }
        return self.id == objectID.id
    }
}
