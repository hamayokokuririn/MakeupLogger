//
//  ColorPalletRepository.swift
//  MakeupLogger
//
//  Created by 齋藤健悟 on 2021/03/28.
//

import Foundation
import UIKit

protocol ColorPalletRepository {
    func getColorPalletList(completion: ([ColorPallet]) -> Void)
    func insertColorPallet(title: String,
                           imageFileName: String,
                           completion: (ColorPallet?) -> Void)
    func updateAnnotation(id: ColorPallet.ColorPalletID,
                          annotation: ColorPalletAnnotation,
                          completion: (ColorPallet?) -> Void)
    func insertAnnotation(id: ColorPallet.ColorPalletID,
                          annotationID: ColorPalletAnnotation.CPID,
                          completion: (ColorPallet?) -> Void)
    
    var cache: [ColorPallet.ColorPalletID: ColorPallet] { get }
}

class ColorPalletRepositoryInMemory: ColorPalletRepository {
    static let shared = ColorPalletRepositoryInMemory()
    
    let colorID1 = ColorPalletAnnotation.CPID(id: 1)
    let colorID2 = ColorPalletAnnotation.CPID(id: 2)
    let colorID3 = ColorPalletAnnotation.CPID(id: 3)
    lazy var colorPalletAnnotation1 = ColorPalletAnnotation(id: colorID1,
                                                            text: "1",
                                                            pointRatioOnImage: PointRatio(x: 0, y: 0))
    lazy var colorPalletAnnotation2 = ColorPalletAnnotation(id: colorID2,
                                                            text: "2",
                                                            pointRatioOnImage: PointRatio(x: 0.3, y: 0))
    lazy var colorPalletAnnotation3 = ColorPalletAnnotation(id: colorID3,
                                                            text: "3",
                                                            pointRatioOnImage: PointRatio(x: 0.6, y: 0))
    let id = ColorPallet.ColorPalletID(idNumber: 0)
    lazy var colorPallet = ColorPallet(id: id,
                                       title: "color_pallet",
                                       image: UIImage(named: "sample_color_pallet"),
                                       annotationList: [colorPalletAnnotation1,
                                                        colorPalletAnnotation2,
                                                        colorPalletAnnotation3])
    
    
    lazy var cache: [ColorPallet.ColorPalletID : ColorPallet] = [id: colorPallet]
    
    private var palletList: [ColorPallet] {
        cache.values.map {$0 as ColorPallet}
    }
    
    private init() {}
    
    func getColorPalletList(completion: ([ColorPallet]) -> Void) {
        completion(palletList)
    }
    
    func insertColorPallet(title: String, imageFileName: String, completion: (ColorPallet?) -> Void) {
        
    }
    
    func updateAnnotation(id: ColorPallet.ColorPalletID, annotation: ColorPalletAnnotation, completion: (ColorPallet?) -> Void) {
        
    }
    
    func insertAnnotation(id: ColorPallet.ColorPalletID, annotationID: ColorPalletAnnotation.CPID, completion: (ColorPallet?) -> Void) {
        
    }
    
    
    
}
