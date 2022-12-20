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

protocol DetectorDelegate:NSObjectProtocol{
    func passDetectorResult(results:[VNRecognizedObjectObservation])
}

class SnackDetector{
    
    weak var detectorDelegate:DetectorDelegate?
    
    static let detector = SnackDetector()
    
    var currentImage: UIImage? = nil
    
    lazy var visionModel: VNCoreMLModel = {
        do {
            //        let coreMLWrapper = SnackLocalizationModel()
            let coreMLWrapper = try SnackDetect(configuration: MLModelConfiguration())
            let visionModel = try VNCoreMLModel(for: coreMLWrapper.model)
            
            if #available(iOS 13.0, *) {
                visionModel.inputImageFeatureName = "image"
                visionModel.featureProvider = try MLDictionaryFeatureProvider(dictionary: [
                    "iouThreshold": MLFeatureValue(double: 0.45),
                    "confidenceThreshold": MLFeatureValue(double: 0.25),
                ])
            }

            return visionModel
        } catch {
            fatalError("Failed to create VNCoreMLModel: \(error)")
        }
    }()
    
    lazy var visionRequest: VNCoreMLRequest = {
        let request = VNCoreMLRequest(model: visionModel, completionHandler: {
            [weak self] request, error in
            self?.processObservations(for: request, error: error)
        })
        
        // NOTE: If you choose another crop/scale option, then you must also
        // change how the BoundingBoxView objects get scaled when they are drawn.
        // Currently they assume the full input image is used.
        request.imageCropAndScaleOption = .scaleFill
//        request.imageCropAndScaleOption = .centerCrop
        return request
    }()
    
    
    
    func predict(image: UIImage) {
        if currentImage == nil{
            currentImage = image
            guard let ciImage = CIImage(image: currentImage!)else{
                print("create image failed")
                return
            }
            // Get additional info from the camera.
            let orientation = CGImagePropertyOrientation(image.imageOrientation)
            let vnhandler = VNImageRequestHandler(ciImage: ciImage, orientation: orientation)
            do {
                try vnhandler.perform([self.visionRequest])
            } catch {
                print("Failed to perform Vision request: \(error)")
            }
            currentImage = nil
        }
    }
    
    func processObservations(for request: VNRequest, error: Error?) {
        //call show function
        DispatchQueue.main.async {
            if let results = request.results as?[VNRecognizedObjectObservation]{
                self.detectorDelegate?.passDetectorResult(results: results)
            }else{
                self.detectorDelegate?.passDetectorResult(results: [])
            }
        }
    }
}


