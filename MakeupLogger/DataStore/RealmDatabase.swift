//
//  RealmDatabase.swift
//  MakeupLogger
//
//  Created by 齋藤健悟 on 2021/04/30.
//

import Foundation
import RealmSwift

class TodoItem2: Object {
    @objc dynamic var id = 0
    @objc dynamic var title = ""
    
    override class func primaryKey() -> String? {
        "id"
    }
}


class TodoRealmDatabase {
    private var realm: Realm!
    static let shared = TodoRealmDatabase()
    
    private init() {
        
        var config = Realm.Configuration.init()
        config.schemaVersion = 1
        realm = try! Realm(configuration: config)
    }
    
    func addTodoItem(title: String) {
        let id: Int
        if let last = realm.objects(TodoItem2.self).last {
            id = last.id + 1
        } else {
            id = 0
        }
        
        
        try! realm.write {
            realm.add(TodoItem2(value: ["title": title, "id": id]))
        }
    }
    
    func select(title: String) -> TodoItem2 {
        let result = realm.objects(TodoItem2.self).first(where: {$0.title == title})
        return result!
    }
    
}
