//
//  MakeupLogRepositoryTests.swift
//  MakeupLoggerTests
//
//  Created by 齋藤健悟 on 2021/02/24.
//

import XCTest
@testable import MakeupLogger

class MakeupLogRepositoryTests: XCTestCase {
    let logID = "log_1"
    let partID = "facePart_1"
    let annotationID = "faceAnnotation_1"
    lazy var faceAnnotation1 = FaceAnnotation(id: annotationID, text: "1")
    
    lazy var annotations = [faceAnnotation1]
    lazy var facePart = FacePart(id: partID, type: "eye", image: UIImage(), annotations: annotations)
    lazy var log = MakeupLog(id: logID, title: "1", image: UIImage(), partsList: [facePart])
    let repository = MakeupLogRepositoryInMemory.shared
    
    let annotationID2 = "faceAnnotation_2"
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
        let newPart = FacePart(id: "facePart_2", type: "nose", image: UIImage(), annotations: [])
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
                                        partID: partID,
                                        faceAnnotation: faceAnnotation2) { log in
            guard let annotations = log?.partsList.first(where: {$0.id == partID})?.annotations else {
                return XCTFail()
            }
            XCTAssertEqual(annotations.count, 2)
            XCTAssertEqual(annotations[1], faceAnnotation2)
        }
    }
}
