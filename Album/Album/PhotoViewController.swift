//
//  PhotoViewController.swift
//  Album
//
//  Created by ziqi on 2022/12/17.
//

import UIKit
import Vision

class PhotoViewController: UIViewController {
    
    @IBOutlet weak var photoNavi: UINavigationItem!
    
    @IBOutlet var photoImage: UIImageView!
    
    let photoManager = PhotoManager.photoManager
    
    let dbHelper = DataBaseHelper.dbHelper
    
    var photo:PhotoDescriptor?
    
    var boxesVisible = false
    
    let detector = SnackDetector.detector
    
    let maxBoundingBoxViews = 10
    var boundingBoxViews = [BoundingBoxView]()
    var colors: [String: UIColor] = [:]
    
    func setUpBoundingBoxViews() {
        for _ in 0..<maxBoundingBoxViews {
            boundingBoxViews.append(BoundingBoxView())
        }
        
        let labels = [
            "apple",
            "banana",
            "cake",
            "candy",
            "carrot",
            "cookie",
            "doughnut",
            "grape",
            "hot dog",
            "ice cream",
            "juice",
            "muffin",
            "orange",
            "pineapple",
            "popcorn",
            "pretzel",
            "salad",
            "strawberry",
            "waffle",
            "watermelon",
        ]
        
        // Make colors for the bounding boxes. There is one color for
        // each class, 20 classes in total.
        var i = 0
        for r: CGFloat in [0.5, 0.6, 0.75, 0.8, 1.0] {
            for g: CGFloat in [0.5, 0.8] {
                for b: CGFloat in [0.5, 0.8] {
                    colors[labels[i]] = UIColor(red: r, green: g, blue: b, alpha: 1)
                    i += 1
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        detector.detectorDelegate = self
        
        photoImage.image = dbHelper.data2image(data: (photo?.image)!)
        
        var constraints = [NSLayoutConstraint]()
        
        constraints.append(photoImage.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor))
        constraints.append(photoImage.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.5))
        constraints.append(photoImage.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor))
        constraints.append(photoImage.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor))
        
        NSLayoutConstraint.activate(constraints)
        
        photoNavi.title = photo?.photoName
        
        photoNavi.rightBarButtonItem = UIBarButtonItem()
        
        photoNavi.rightBarButtonItem?.image = UIImage(systemName: "line.3.horizontal")
        
        photoNavi.rightBarButtonItem?.target = self
        
        photoNavi.rightBarButtonItem?.action = #selector(showImageMenu)
        
        setUpBoundingBoxViews()
        
        // Add the bounding box layers to the UI, on top of the image view.
        for box in self.boundingBoxViews {
            box.addToLayer(self.photoImage.layer)
            box.hide()
        }
    }
    
    private func popOverHelper(controller: UIAlertController){
        let popover = controller.popoverPresentationController
        if let popover = popover{
            popover.sourceView = self.view
            popover.sourceRect = self.view.bounds
            popover.permittedArrowDirections = UIPopoverArrowDirection()
        }
        self.present(controller, animated: true)
    }
    
    @objc func showImageMenu(_ sender:UIButton){
        let sheet = UIAlertController(title: "Options", message: nil, preferredStyle: .actionSheet)
        
        sheet.addAction(UIAlertAction(title: "Show detail", style: .default, handler: { _ in
            let name = self.photo?.photoName ?? "anonymous"
            let date = self.dbHelper.getDateStr(date: self.photo?.addedDate)
            let label = self.photo?.label ?? "other"
            let confidence = self.photo?.labelConfidence ?? 0
            let infostr = "Name: \(name)\n" + "Date: \(date)\n" + "Category: \(label)\n"  + "" + String(format: "Classification confidence: %.1f%%\n", confidence * 100)
            let info = UIAlertController(title: "Detail", message: infostr, preferredStyle: .alert)
            info.addAction(UIAlertAction(title: "Cancel", style: .destructive))
            self.popOverHelper(controller: info)
        }))
        
        sheet.addAction(UIAlertAction(title: "Show bounding boxes", style: .default, handler: {
            _ in
            self.detector.predict(image: self.photoImage.image!)
        }))
        
        sheet.addAction(UIAlertAction(title: "Hide bounding boxes", style: .default, handler: {
            _ in
            for box in self.boundingBoxViews{
                box.hide()
            }
        }))
        
        sheet.addAction(UIAlertAction(title: "Rename", style: .default, handler: {
            _ in
            let textVC = UIAlertController(title: "Rename to", message: "New photo name", preferredStyle: .alert)
            textVC.addTextField()
            textVC.addAction(UIAlertAction(title: "Submit", style: .cancel, handler: {
                _ in
                guard let field = textVC.textFields?.first, let text = field.text, !text.isEmpty else{
                    return
                }
                self.photoManager.changePhotoName(photo: self.photo!, name: text)
            }))
            self.popOverHelper(controller: textVC)
        }))
        
        sheet.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: {
            _ in
            let confirm = UIAlertController(title: "Confirm Deletion", message: "Are you sure you want to delete the photo?", preferredStyle: .alert)
            confirm.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: {
                _ in
                self.photoManager.deletePhoto(photo: self.photo!)
                self.photo = nil
                self.navigationController?.popViewController(animated: true)
            }))
            confirm.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            self.popOverHelper(controller: confirm)
        }))
        
        sheet.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
        
        popOverHelper(controller: sheet)
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension PhotoViewController:DetectorDelegate{
    func passDetectorResult(results: [VNRecognizedObjectObservation]) {
        print("detector result received")
        showBoxes(predictions: results)
    }
    
    func showBoxes(predictions: [VNRecognizedObjectObservation]){
        for i in 0..<boundingBoxViews.count{
            if i < predictions.count{
                let predict = predictions[i]
                let radius = (photoImage.image?.size.width)! / (photoImage.image?.size.height)!
                let height = photoImage.bounds.height
                let width = height * radius
                let offsetX = (photoImage.bounds.width - width) / 2
                let offsetY = (photoImage.bounds.height - height) / 2
                let scale = CGAffineTransform.identity.scaledBy(x: width, y: height)
                let transform = CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: offsetX, y: -height - offsetY)
                let rect = predict.boundingBox.applying(scale).applying(transform)
                
                let best = predict.labels[0].identifier
                let confidence = predict.labels[0].confidence
                let label = String(format: "%@ %.1f", best,confidence*100)
                let color = colors[best] ?? UIColor.red
                boundingBoxViews[i].show(frame: rect, label: label, color: color)
                
            }else{
                boundingBoxViews[i].hide()
            }
        }
    }
}
