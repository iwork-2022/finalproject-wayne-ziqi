//
//  PhotoDescriptor+CoreDataProperties.swift
//  Album
//
//  Created by ziqi on 2022/12/19.
//
//

import Foundation
import CoreData


extension PhotoDescriptor {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PhotoDescriptor> {
        return NSFetchRequest<PhotoDescriptor>(entityName: "PhotoDescriptor")
    }

    @NSManaged public var photoName: String?
    @NSManaged public var addedDate: Date?
    @NSManaged public var label: String?
    @NSManaged public var labelConfidence: Double
    @NSManaged public var image: Data?

}

extension PhotoDescriptor : Identifiable {

}
