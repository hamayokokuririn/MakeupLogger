//
//  ColorPalletViewModel.swift
//  MakeupLogger
//
//  Created by 齋藤健悟 on 2021/04/04.
//

import Foundation
import UIKit

final class ColorPalletViewModel: NSObject {
    enum ValidateError: Error {
        case titleMissing
        case imageMissing
    }
    
    let colorPalletID: ColorPallet.ColorPalletID
    private let repository: ColorPalletRepository
    var title: String?
    var image: UIImage?
    var annotationList: [ColorPalletAnnotation] = []
    
    var completeAction: (() -> Void)?
    
    init(colorPalletID: ColorPallet.ColorPalletID, repository: ColorPalletRepository) {
        self.colorPalletID = colorPalletID
        self.repository = repository
        
        super.init()
        repository.getColorPalletList { palletList in
            if let colorPallet = palletList.first(where: {
                $0.id == colorPalletID
            }) {
                self.title = colorPallet.title
                self.image = colorPallet.image
                self.annotationList = colorPallet.annotationList
            }
        }
    }
    
    func addAnnotation(completion: (ColorPallet?) -> Void) {
        repository.insertAnnotation(id: colorPalletID) { pallet in
            completion(pallet)
            if let pallet = pallet {
                annotationList = pallet.annotationList
            }
        }
    }
    
    func complete() throws {
        guard let title = title else {
            throw ValidateError.titleMissing
        }
        guard let image = image else {
            throw ValidateError.imageMissing
        }
        repository.updateColorPallet(id: colorPalletID,
                                     title: title,
                                     image: image) { _ in
            completeAction?()
        }
    }
    
    func didAnnotationUpdate(_ view: AnnotationMoveImageView<ColorPalletViewController>, didTouched annotationViewFrame: CGRect, and id: AnnotationID) {
        repository.getColorPalletList { palletList in
            if let colorPallet = palletList.first(where: {
                $0.id == colorPalletID
            }) {
                guard let id = id as? ColorPalletAnnotation.CPID,
                      var annotation = colorPallet.annotationList.first(where: {
                        $0.id == id
                      }) else {return}
                let rect = view.imageRect()
                let point = CGPoint(x: annotationViewFrame.minX - rect.minX,
                                    y: annotationViewFrame.minY - rect.minY)
                let pointRatio = PointRatio(parentViewSize: rect.size,
                                            annotationPoint: point)
                annotation.pointRatioOnImage = pointRatio
                repository.updateAnnotation(id: colorPalletID,
                                            annotation: annotation,
                                            completion: { _ in })
            }
        }
    }
}

extension ColorPalletViewModel: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        title = textField.text
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
}
