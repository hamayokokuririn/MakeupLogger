//
//  AnnotationDetailViewModel.swift
//  MakeupLogger
//
//  Created by 齋藤健悟 on 2021/02/14.
//

import Foundation

struct AnnotationDetailViewModel {
    let logID: MakeupLog.ID
    let facePartID: FacePart.ID
    var annotation: FaceAnnotation
    let makeupLogRepository: MakeupLogRepository
    let colorPalletRepository: ColorPalletRepository
    
    var didFinishUpdateAnnotation: ((String) -> Void)?
    
    mutating func setComment(_ text: String) {
        annotation.comment = Comment(text: text)
    }
    
    func getColorPallet(completion: (ColorPallet) -> Void) {
        colorPalletRepository.getColorPalletList { palletList in
            guard let pallet = palletList.first(where: {
                $0.id == annotation.selectedColorPalletID
            }) else {return}
            completion(pallet)
        }
    }
    
    mutating func updateSelectedAnnotation(id: AnnotationID) {
        annotation.selectedColorPalletAnnotationID = id as? ColorPalletAnnotation.CPID
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
                        didFinishUpdateAnnotation?(colorPalletAnnotation.text)
                    }
                }
            }
        }
    }
}
