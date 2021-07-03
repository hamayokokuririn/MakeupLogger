//
//  AnnotationDetailViewController.swift
//  MakeupLogger
//
//  Created by 齋藤健悟 on 2021/02/14.
//

import Foundation
import UIKit

final class AnnotationDetailViewController: UIViewController {
    var viewModel: AnnotationDetailViewModel
    
    @IBOutlet weak var commentTextView: UITextView!
    
    @IBOutlet weak var selectedColorPalletName: UILabel!
    @IBOutlet weak var selectedColorPalletAnnotationName: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    private lazy var colorPalletImage: AnnotationMoveImageView = {
        return AnnotationMoveImageView<AnnotationDetailViewController>()
    }()
    
    @IBOutlet weak var changeColorPalletButton: UIButton!
    
    init(logID: MakeupLogID, facePartID: FacePartID, annotation: FaceAnnotation, makeupLogRepository: MakeupLogRepository, colorPalletRepository: ColorPalletRepository) {
        self.viewModel = AnnotationDetailViewModel(logID: logID, facePartID: facePartID, annotation: annotation, makeupLogRepository: makeupLogRepository, colorPalletRepository: colorPalletRepository)
        super.init(nibName: nil, bundle: nil)
        
        view.backgroundColor = .white
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(close))
        
        commentTextView.text = annotation.comment
        commentTextView.delegate = self
        
        colorPalletImage.isUserInteractionEnabled = true
        colorPalletImage.movesSubviews = false
        colorPalletImage.delegate = self
        
        imageView = colorPalletImage
        
        changeColorPalletButton.addTarget(self, action: #selector(didPushChangeColorPalletButton), for: .touchUpInside)
        
        viewModel.getColorPallet() { pallet in
            setupColorPallet(colorPallet: pallet)
        }
        
        viewModel.didFinishUpdateColorPallet = { colorPallet in
            self.setupColorPallet(colorPallet: colorPallet)
        }
        
        viewModel.didFinishUpdateAnnotation = { text in
            self.selectedColorPalletAnnotationName.text = text
            self.selectedColorPalletAnnotationName.sizeToFit()
        }
    }
    
    private func setupColorPallet(colorPallet: ColorPallet) {
        selectedColorPalletName.text = colorPallet.title
        if let data = ColorPalletRealmRepository.imageData(imagePath: colorPallet.imagePath) {
            colorPalletImage.image = UIImage(data: data)
        }
        colorPalletImage.subviews.forEach {
            $0.removeFromSuperview()
        }
        colorPallet.annotationList.forEach {
            let view = AnnotationView(annotation: $0)
            colorPalletImage.addSubview(view)
        }
        colorPalletImage.adjustAnnotationViewFrame()
        DispatchQueue.main.async {
            let selectedColorPalletAnnotationID = self.viewModel.annotation.selectedColorPalletAnnotationID
            let selectedColorAnnotation = colorPallet.annotationList.first(where: {
                $0.id == selectedColorPalletAnnotationID
            })
            self.selectedColorPalletAnnotationName.text = selectedColorAnnotation?.text ?? "---"
            self.colorPalletImage.activateAnnotation(for: selectedColorPalletAnnotationID)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func didPushChangeColorPalletButton() {
        let vc = MakeupLogListViewController(mode: .selectColorPallet,
                                             makeupLogRepository: viewModel.makeupLogRepository,
                                             colorPalletRepository: viewModel.colorPalletRepository)
        vc.viewModel.didSelectColorPallet = { colorPallet in
            self.viewModel.updateSelectedColorPallet(colorPallet: colorPallet)
            self.navigationController?.popViewController(animated: true)
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func close() {
        guard let pc = navigationController?.presentationController else {return}
        pc.delegate?.presentationControllerDidDismiss?(pc)
    }
}

extension AnnotationDetailViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        guard let text = textView.text else {return}
        viewModel.setComment(text)
    }
    
}

extension AnnotationDetailViewController: AnnotationMoveImageViewDelegate {
    typealias AnnotationType = ColorPalletAnnotationObject
    
    func annotationMoveImageView(_ view: AnnotationMoveImageView<AnnotationDetailViewController>, didTouched annotationViewFrame: CGRect, and id: AnnotationType.ID) {
        viewModel.updateSelectedAnnotation(id: id)
        colorPalletImage.activateAnnotation(for: id)
    }
}
