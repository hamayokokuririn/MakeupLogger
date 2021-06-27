//
//  MakeupLogRepositoryTests.swift
//  MakeupLoggerTests
//
//  Created by 齋藤健悟 on 2021/02/24.
//

import XCTest
@testable import MakeupLogger

class MakeupLogRepositoryTests: XCTestCase {
    lazy var logID: MakeupLogID = {
        let id = MakeupLogID()
        return id
    }()
    lazy var partID: FacePartID = {
        let id = FacePartID()
        return id
    }()
    lazy var annotationID: FaceAnnotationID = {
        let id = FaceAnnotationID()
        return id
    }()
    lazy var faceAnnotation1: FaceAnnotationObject = {
        let annotation = FaceAnnotationObject()
        annotation.id = annotationID
        annotation.text = "1"
        return annotation
    }()

    lazy var annotations = [faceAnnotation1]
    lazy var facePart = FacePart.make(id: partID, type: "eye", imagePath: "", annotations: annotations)
    lazy var log = MakeupLog.make(id: logID, title: "1", imagePath: "", partsList: [facePart])
    let repository = MakeupLogRepositoryInMemory.shared

    lazy var annotationID2: FaceAnnotationID = {
        let id = FaceAnnotationID()
        return id
    }()
    lazy var faceAnnotation2: FaceAnnotationObject = {
        let annotation = FaceAnnotationObject()
        annotation.id = annotationID2
        annotation.text = "2"
        return annotation
    }()

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
        let id = FacePartID()
        let newPart = FacePart.make(id: id, type: "nose", imagePath: "", annotations: [])
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
                                        faceAnnotation: faceAnnotation2.makeAnnotation()) { log in
            XCTAssertNil(log)
        }

        faceAnnotation1.comment = "test"
        repository.updateFaceAnnotation(logID: logID,
                                        partID: partID,
                                        faceAnnotation: faceAnnotation1.makeAnnotation()) { log in
            XCTAssertEqual(log!.partsList[0].annotations.count, 1)
            XCTAssertEqual(log!.partsList[0].annotations[0], faceAnnotation1)
            XCTAssertEqual(log!.partsList[0].annotations[0].comment, faceAnnotation1.comment)
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
            XCTAssertEqual(annotations[1].id!.id, faceAnnotation2.id!.id)
        }
    }

    func testInsertFacePart() {
        let partList = repository.logMap[logID]?.partsList
        XCTAssertEqual(partList!.count, 1)

        let nextID = FacePartID()
        repository.nextFacePartID = nextID
        repository.insertFacePart(logID: logID, type: "nose", image: #imageLiteral(resourceName: "sample_eye_line")) { (log) in
            XCTAssertEqual(log!.partsList.count, 2)
            XCTAssertEqual(log!.partsList[0].id, partID)
            XCTAssertEqual(log!.partsList[1].id!.id, nextID.id)
        }
    }

    func testInsertFaceAnnotation_新しいパーツに対して() {
        repository.insertFacePart(logID: logID,
                                  type: "nose",
                                  image: #imageLiteral(resourceName: "sample_eye_line"),
                                  completion: {_ in })
        let partList = repository.logMap[logID]?.partsList
        XCTAssertEqual(partList!.count, 2)

        let newPartID = partList![1].id!
        let nextID = FaceAnnotationID()
        repository.nextFaceAnnotationID = nextID
        repository.insertFaceAnnotation(logID: logID,
                                        partID: newPartID) { log in
            guard let annotations = log?.partsList.first(where: {$0.id == newPartID})?.annotations else {
                return XCTFail()
            }
            XCTAssertEqual(annotations.count, 1)
            XCTAssertEqual(annotations[0].id!.id, nextID.id)
        }
    }

    func testInsertMakeupLog() {
        XCTAssertEqual(repository.logMap.count, 1)
        repository.insertMakeupLog(title: "test",
                                   body: "test_body",
                                   image: #imageLiteral(resourceName: "sample_eye_line")) { (log) in
            guard let log = log else {
                XCTFail()
                return
            }
            XCTAssertEqual(log.title, "test")
            XCTAssertEqual(log.body, "test_body")
            let result = MakeupLogID()
            XCTAssertEqual(log.id!.id, result.id)
            XCTAssertEqual(log.partsList.count, 0)
        }
    }
}
