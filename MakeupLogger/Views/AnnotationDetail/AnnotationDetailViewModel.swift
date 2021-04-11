//
//  AnnotationDetailViewModel.swift
//  MakeupLogger
//
//  Created by 齋藤健悟 on 2021/02/14.
//

import Foundation

struct AnnotationDetailViewModel {
    var annotation: FaceAnnotation
    let repository: ColorPalletRepository
    
    mutating func setComment(_ text: String) {
        annotation.comment = Comment(text: text)
    }
    
    func getColorPallet(completion: (ColorPallet) -> Void) {
        repository.getColorPalletList { palletList in
            guard let pallet = palletList.first(where: {
                $0.id == annotation.selectedColorPalletID
            }) else {return}
            completion(pallet)
        }
    }
}
