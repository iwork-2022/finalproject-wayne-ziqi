//
//  PhotoManager.swift
//  Album
//
//  Created by ziqi on 2022/12/13.
//

// MARK: describe photos

import Foundation
import UIKit

protocol PhotoManagerDelegate:NSObjectProtocol{
    func updateContent()
}

class PhotoManager:NSObject{
    //
    
    var album = [String:[PhotoDescriptor]]()
    
    var albumSequence = [PhotoDescriptor]()
    
    var categorySequence = [String]()
    
    let dbHelper = DataBaseHelper.dbHelper
    
    let classifier = SnackClassifier.classifier
    var classifierLabel:String? = nil
    var classifierConfidence:Double? = nil
    
    var managerDelegateGalary:PhotoManagerDelegate?
    var managerDelegateCateTab:PhotoManagerDelegate?
    var managerDelegateCate:PhotoManagerDelegate?
    
    static let photoManager = PhotoManager()

    var categoryNum:Int{
        get{
            return categorySequence.count
        }
    }
    
    var albumSize:Int{
        get{
            return albumSequence.count
        }
    }
    
    public func getAllPhotos(){
        let photos = dbHelper.retreivePhotos()
        if let photos = photos{
            
            var newAlbum = [String:[PhotoDescriptor]]()
            var newCate = [String]()
            for photo in photos{
                if newAlbum[photo.label!] == nil{
                    newAlbum[photo.label!] = [PhotoDescriptor]()
                    newCate.append(photo.label!)
                }
                newAlbum[photo.label!]?.append(photo)
            }
            album = newAlbum
            categorySequence = newCate
            albumSequence = photos
            managerDelegateGalary?.updateContent()
            managerDelegateCateTab?.updateContent()
            managerDelegateCate?.updateContent()
        }
    }
    
    public func addPhoto(image:UIImage, name: String?){
        classifier.classifierDelegate = self
        classifier.classify(image: image)
        
        let date = Date()
        
        dbHelper.savePhoto(photoName: name ?? dbHelper.getDateStr(date: date), addedDate: date, label: self.classifierLabel!, labelConfidence: self.classifierConfidence!, image: image)
        
        getAllPhotos()
        
        self.classifierLabel = nil
        self.classifierConfidence = nil
    }
    
    public func deletePhoto(photo:PhotoDescriptor){
        self.dbHelper.deletePhoto(photo: photo)
        getAllPhotos()
    }
    
    public func changePhotoName(photo: PhotoDescriptor, name:String){
        dbHelper.updatePhoto(photo: photo, name: name)
//        getAllPhotos()
    }
}

extension PhotoManager:ClassifierDelegate{
    func passClassifierResult(label: String, confidence: Double) {
        if self.classifierLabel != nil || self.classifierConfidence != nil{
            print("last add hasn't finished yet")
            return
        }
        if label == ""{
            return
        }else if confidence < 0.7{
            print("dbg1")
            self.classifierLabel = "other"
            self.classifierConfidence = confidence
        }else{
            print("dbg2")
            self.classifierLabel = label
            self.classifierConfidence = confidence
        }
    }
}
