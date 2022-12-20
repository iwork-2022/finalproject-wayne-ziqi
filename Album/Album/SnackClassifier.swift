//
//  SnackClassifier.swift
//  Album
//
//  Created by ziqi on 2022/12/16.
//

import UIKit
import Foundation
import Vision
import CoreML

protocol ClassifierDelegate:NSObjectProtocol{
    func passClassifierResult(label:String, confidence:Double)
}

class SnackClassifier{
    
    weak var classifierDelegate:ClassifierDelegate?
    
    static let classifier = SnackClassifier()
    
    lazy var classificationRequest:VNCoreMLRequest = {
        do{
            let snacks = try SGClassifier(configuration: MLModelConfiguration())
            let model = try VNCoreMLModel(for: snacks.model)
            let vnRequest = VNCoreMLRequest(model: model, completionHandler: {
                [weak self] request, error in
                self?.processObservations(for: request, error: error)
            })
            vnRequest.imageCropAndScaleOption = .centerCrop
            
            return vnRequest
        }catch{
            fatalError("load module error")
        }
    }()
    
    func classify(image: UIImage) {
        //TODO: use VNImageRequestHandler to perform a classification request
        guard let ciImage = CIImage(image: image)else{
            print("create image failed")
            return
        }
        let orientation = CGImagePropertyOrientation(image.imageOrientation)
//        DispatchQueue.global(qos: .userInitiated).async {
            let vnhandler = VNImageRequestHandler(ciImage: ciImage, orientation: orientation)
            do{
                try vnhandler.perform([self.classificationRequest])
            }catch{
                print("failed to classify image: \(error)")
            }
//        }
    }
    
    func processObservations(for request: VNRequest, error: Error?){
//        DispatchQueue.main.async {
            if let result = request.results as? [VNClassificationObservation]{
                if result.isEmpty{
                    self.classifierDelegate?.passClassifierResult(label: "", confidence: 0.0)
                }
                else{
                    print(result[0].identifier)
                    print(result[0].confidence)
                    self.classifierDelegate?.passClassifierResult(label: result[0].identifier, confidence: Double(result[0].confidence))
                }
            }else if let error = error{
                print("observe error: \(error)")
            }else{
                print("???")
            }
//        }
    }
}


