//
//  DatabaseHelper.swift
//  Album
//
//  Created by ziqi on 2022/12/19.
//

import Foundation
import UIKit
import CoreData
class DataBaseHelper {
    
    static let dbHelper = DataBaseHelper()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    func savePhoto(photoName:String, addedDate:Date, label:String, labelConfidence: Double, image:UIImage){
        let photo = NSEntityDescription.insertNewObject(forEntityName: "PhotoDescriptor", into: context) as! PhotoDescriptor
        photo.image = image.jpegData(compressionQuality: 1) as Data?
        photo.addedDate = addedDate
        photo.photoName = photoName
        photo.label = label
        photo.labelConfidence = labelConfidence
        
        do{
            try context.save()
            print("photo saved")
        }catch{
            print("save photo error")
        }
    }
    
    func retreivePhotos()->[PhotoDescriptor]?{
        var photos:[PhotoDescriptor]? = nil
        do{
            photos = try context.fetch(PhotoDescriptor.fetchRequest())
        }catch{
            print("retreive photo error")
        }
        return photos
    }
    
    func data2image(data:Data)->UIImage{
        if let image =  UIImage(data: data){
            return image
        }else{
            print("translate image error")
            return UIImage()
        }
    }
    
    func getDateStr(date: Date?)->String{
        if let date = date{
            let today = date
            let year = Calendar.current.component(.year, from: today)
            let month = Calendar.current.component(.month, from: today)
            let day = Calendar.current.component(.day, from: today)
            let hours = Calendar.current.component(.hour, from: today)
            let minute = Calendar.current.component(.minute, from: today)
            let second = Calendar.current.component(.second, from: today)
            return "\(year)-\(month)-\(day)_\(hours):\(minute):\(second)"
        }
        else{
            return "unknown"
        }
        
    }
    
    func deletePhoto(photo: PhotoDescriptor){
        context.delete(photo)
        do{
            try context.save()
        }catch{
            print("delete photo error")
        }
    }
    
    func updatePhoto(photo: PhotoDescriptor, name:String){
        photo.photoName = name
        do{
            try context.save()
        }catch{
            print("update photo error")
        }
        
    }
}
