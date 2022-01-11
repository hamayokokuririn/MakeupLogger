//
//  AnnotationDetailViewModel.swift
//  MakeupLogger
//
//  Created by 齋藤健悟 on 2021/02/14.
//

import Foundation

struct AnnotationDetailViewModel {
    let logID: MakeupLogID
    let facePartID: FacePartID
    var annotation: FaceAnnotation
    let makeupLogRepository: MakeupLogRepository
    let colorPalletRepository: ColorPalletRepository
    
    var didFinishUpdateAnnotation: ((String) -> Void)?
    var didFinishUpdateColorPallet: ((ColorPallet) -> Void)?
    
    mutating func setTitle(_ text: String) {
        annotation.title = text
    }
    
    mutating func setComment(_ text: String) {
        annotation.comment = text
    }
    
    func getColorPallet(completion: (ColorPallet) -> Void) {
        colorPalletRepository.getColorPalletList { palletList in
            guard let pallet = palletList.first(where: {
                $0.id == annotation.selectedColorPalletID
            }) else {return}
            completion(pallet)
        }
    }
    
    mutating func updateSelectedColorPallet(colorPallet: ColorPallet) {
        annotation.selectedColorPalletID = colorPallet.id
        makeupLogRepository.updateFaceAnnotation(logID: logID,
                                                 partID: facePartID,
                                                 faceAnnotation: annotation) { log in
            // 描画の更新
            didFinishUpdateColorPallet?(colorPallet)
        }
    }
    
    mutating func updateSelectedAnnotation(id: AnnotationID) {
        annotation.selectedColorPalletAnnotationID = id as? ColorPalletAnnotationID
        makeupLogRepository.updateFaceAnnotation(logID: logID,
                                                 partID: facePartID,
                                                 faceAnnotation: annotation) { _ in
            colorPalletRepository.getColorPalletList { list in
                if let pallet = list.first(where: {
                    $0.id == annotation.selectedColorPalletID
                }) {
                    if let colorPalletAnnotation = pallet.annotationList.first(where: {
                        $0.id == annotation.selectedColorPalletAnnotationID
                    }) {
                        didFinishUpdateAnnotation?(colorPalletAnnotation.title)
                    }
                }
            }
        }
    }
}
