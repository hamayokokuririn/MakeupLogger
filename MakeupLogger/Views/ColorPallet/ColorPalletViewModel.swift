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
    }
    
    let colorPalletID: ColorPalletID
    private let repository: ColorPalletRepository
    var title: String?
    var image: UIImage?
    var annotationList: [ColorPalletAnnotation] = []
    
    var completeAction: (() -> Void)?
    
    init(colorPalletID: ColorPalletID, repository: ColorPalletRepository) {
        self.colorPalletID = colorPalletID
        self.repository = repository
        
        super.init()
        repository.getColorPalletList { palletList in
            if let colorPallet = palletList.first(where: {
                $0.id == colorPalletID
            }) {
                self.title = colorPallet.title
                if let imagePath = colorPallet.imagePath,
                   let data = FileIOUtil.getImageDataFromDocument(path: imagePath) {
                    self.image = UIImage(data: data)
                }
                var list = [ColorPalletAnnotation]()
                colorPallet.annotationList.forEach {
                    list.append($0.makeAnnotation())
                }
                self.annotationList = list
            }
        }
    }
    
    func addAnnotation(completion: (ColorPallet?) -> Void) {
        repository.insertAnnotation(id: colorPalletID) { pallet in
            if let pallet = pallet {
                var list = [ColorPalletAnnotation]()
                pallet.annotationList.forEach {
                    list.append($0.makeAnnotation())
                }
                annotationList = list
            }
            completion(pallet)
        }
    }
    
    func complete() throws {
        guard let title = title else {
            throw ValidateError.titleMissing
        }
        repository.updateColorPallet(id: colorPalletID,
                                     title: title,
                                     image: image,
                                     annotations: annotationList) { _ in
            completeAction?()
        }
    }
    
    func didAnnotationUpdate(_ view: AnnotationMoveImageView<ColorPalletViewController>, didTouched annotationViewFrame: CGRect, and id: AnnotationID) {
        repository.getColorPalletList { palletList in
            if let colorPallet = palletList.first(where: {
                $0.id == colorPalletID
            }) {
                guard let id = id as? ColorPalletAnnotationID,
                      let annotationObject = colorPallet.annotationList.first(where: {
                        $0.id == id
                      }) else {return}
                let rect = view.imageRect()
                let point = CGPoint(x: annotationViewFrame.minX - rect.minX,
                                    y: annotationViewFrame.minY - rect.minY)
                let pointRatio = PointRatio.make(parentViewSize: rect.size,
                                                 annotationPoint: point)
                let annotation = annotationObject.makeAnnotation(point: pointRatio)
                repository.updateAnnotation(id: colorPalletID,
                                            annotation: annotation,
                                            completion: { colorPallet in
                    if let list = colorPallet?.annotationList {
                        self.annotationList = list.map { $0.makeAnnotation()}
                    }
                })
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

extension ColorPalletViewModel: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        annotationList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ColorPalletAnnotationTableViewCell", for: indexPath) as! ColorPalletAnnotationTableViewCell
        
        let annotation = annotationList[indexPath.row]
        cell.setLabel(annotation.text)
        cell.setTextTitle(annotation.title)
        cell.delegate = self
        cell.id = annotation.id
        return cell
    }
    
    
}

extension ColorPalletViewModel: ColorPalletAnnotationTableViewCellDelegate {
    func didEnded(_ cell: ColorPalletAnnotationTableViewCell, editing text: String) {
        guard let id = cell.id,
              let index = annotationList.firstIndex(where: {$0.id == id}) else {
                  return
              }
        annotationList[index].title = text
        repository.updateAnnotation(id: colorPalletID, annotation: annotationList[index], completion: {_ in })
    }
}
