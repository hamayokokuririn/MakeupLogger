//
//  MakeupLogRepositoryTests.swift
//  MakeupLoggerTests
//
//  Created by 齋藤健悟 on 2021/02/24.
//

import XCTest
@testable import MakeupLogger

class MakeupLogRepositoryTests: XCTestCase {
    let logID = MakeupLog.ID(idNumber: 1)
    let partID = FacePart.ID(idNumber: 1)
    let annotationID = FaceAnnotation.FAID(id: 1)
    lazy var faceAnnotation1 = FaceAnnotation(id: annotationID, text: "1")
    
    lazy var annotations = [faceAnnotation1]
    lazy var facePart = FacePart(id: partID, type: "eye", image: UIImage(), annotations: annotations)
    lazy var log = MakeupLog(id: logID, title: "1", image: UIImage(), partsList: [facePart])
    let repository = MakeupLogRepositoryInMemory.shared
    
    let annotationID2 = FaceAnnotation.FAID(id: 2)
    lazy var faceAnnotation2 = FaceAnnotation(id: annotationID2, text: "2")
    
    override func setUp() {
        repository.setLog(logMap: [logID: log])
    }
    
    func testGet() {
        repository.getLogList { logList in
            XCTAssertEqual(logList.count, 1)
            XCTAssertEqual(logList[0].id, log.id)
        }
    }
    
    func testUpdateFacePart() throws {
        let id = FacePart.ID(idNumber: 2)
        let newPart = FacePart(id: id, type: "nose", image: UIImage(), annotations: [])
        repository.updateFacePart(logID: logID, part: newPart) { log in
            XCTAssertNil(log)
        }
        
        facePart.annotations.append(faceAnnotation2)
        repository.updateFacePart(logID: logID, part: facePart) { log in
            XCTAssertEqual(log!.partsList.count, 1)
            XCTAssertEqual(log!.partsList[0].annotations.count, 2)
            XCTAssertEqual(log!.partsList[0].annotations[0].id, annotationID)
            XCTAssertEqual(log!.partsList[0].annotations[1].id, annotationID2)
        }
    }
    
    func testUpdateFaceAnnotation() {
        repository.updateFaceAnnotation(logID: logID,
                                        partID: partID,
                                        faceAnnotation: faceAnnotation2) { log in
            XCTAssertNil(log)
        }
        
        faceAnnotation1.comment = Comment(text: "test")
        repository.updateFaceAnnotation(logID: logID,
                                        partID: partID,
                                        faceAnnotation: faceAnnotation1) { log in
            XCTAssertEqual(log!.partsList[0].annotations.count, 1)
            XCTAssertEqual(log!.partsList[0].annotations[0], faceAnnotation1)
            XCTAssertEqual(log!.partsList[0].annotations[0].comment?.text, faceAnnotation1.comment?.text)
        }
    }
    
    func testInsertFaceAnnotation() {
        let annotations = repository.logMap[logID]?.partsList.first(where: {$0.id == partID})?.annotations
        XCTAssertEqual(annotations!.count, 1)
        
        repository.insertFaceAnnotation(logID: logID,
                                        partID: partID) { log in
            guard let annotations = log?.partsList.first(where: {$0.id == partID})?.annotations else {
                return XCTFail()
            }
            XCTAssertEqual(annotations.count, 2)
            XCTAssertEqual(annotations[1], faceAnnotation2)
        }
    }
    
    func testInsertFacePart() {
        let partList = repository.logMap[logID]?.partsList
        XCTAssertEqual(partList!.count, 1)

        let id = FacePart.ID(idNumber: 2)
        repository.insertFacePart(logID: logID, type: "nose", image: UIImage()) { (log) in
            XCTAssertEqual(log!.partsList.count, 2)
            XCTAssertEqual(log!.partsList[0].id, partID)
            XCTAssertEqual(log!.partsList[1].id, id)
        }
    }
    
    func testInsertFaceAnnotation_新しいパーツに対して() {
        repository.insertFacePart(logID: logID,
                                  type: "nose",
                                  image: UIImage(), completion: {_ in })
        let partList = repository.logMap[logID]?.partsList
        XCTAssertEqual(partList!.count, 2)

        let newPartID = partList![1].id
        repository.insertFaceAnnotation(logID: logID,
                                        partID: newPartID) { log in
            guard let annotations = log?.partsList.first(where: {$0.id == newPartID})?.annotations else {
                return XCTFail()
            }
            XCTAssertEqual(annotations.count, 1)
            XCTAssertEqual(annotations[0].id, FaceAnnotation.FAID())
        }
    }
    
    func testInsertMakeupLog() {
        XCTAssertEqual(repository.logMap.count, 1)
        repository.insertMakeupLog(title: "test",
                                   body: "test_body",
                                   image: UIImage()) { (log) in
            guard let log = log else {
                XCTFail()
                return
            }
            XCTAssertEqual(log.title, "test")
            XCTAssertEqual(log.body, "test_body")
            XCTAssertEqual(log.id, MakeupLog.ID(idNumber: 2))
            XCTAssertEqual(log.partsList.count, 0)
        }
    }
}
