//
//  FaceAnnotationRepository.swift
//  MakeupLogger
//
//  Created by 齋藤健悟 on 2021/02/20.
//

import Foundation
import UIKit

protocol MakeupLogRepository {
    func fetch(completion: ([MakeupLog]) -> Void)
}

class MakeupLogRepositoryInMemory: MakeupLogRepository {
    lazy var log: MakeupLog = MakeupLog(id: "makeupLog_1", title: "makeup_sample", image: #imageLiteral(resourceName: "sample_face"),
                                        partsList: [eye])
    lazy var eye: FacePart = { FacePart(type: "eye", image: #imageLiteral(resourceName: "sample_eye_line"),
                                        annotations: [])}()
    lazy var eyeAnnotation: FaceAnnotation = { FaceAnnotation(id: "eye_1",
                                                              text: "1",
                                                              pointRatioOnImage: PointRatio(x: 0.1, y: 0.2),
                                                              comment: Comment(text: "暗めにする"),
                                                              colorPallet: colorPallet,
                                                              selectedColorPalletAnnotationID: "1")}()
    
    let colorPalletAnnotation1 = ColorPalletAnnotation(id: "1",
                                                       text: "1",
                                                       pointRatioOnImage: PointRatio(x: 0, y: 0))
    let colorPalletAnnotation2 = ColorPalletAnnotation(id: "2",
                                                       text: "2",
                                                       pointRatioOnImage: PointRatio(x: 0.3, y: 0))
    let colorPalletAnnotation3 = ColorPalletAnnotation(id: "3",
                                                       text: "3",
                                                       pointRatioOnImage: PointRatio(x: 0.6, y: 0))
    lazy var colorPallet = ColorPallet(id: ColorPallet.ColorPalletID(id: "test"),
                                       title: "color_pallet",
                                       imageFileName: "sample_color_pallet",
                                       annotationList: [colorPalletAnnotation1,
                                                        colorPalletAnnotation2,
                                                        colorPalletAnnotation3])
    func fetch(completion: (([MakeupLog]) -> Void)) {
        completion([log])
    }
}
