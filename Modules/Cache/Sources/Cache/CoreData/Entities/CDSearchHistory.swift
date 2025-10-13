//
//  CDSearchHistory.swift
//  Cache
//
//  Created by Ivan Tonial IP.TV on 09/10/25.
//

import CoreData
import Foundation

@objc(CDSearchHistory)
public class CDSearchHistory: NSManagedObject {
    @NSManaged public var query: String
    @NSManaged public var timestamp: Date
    @NSManaged public var resultCount: Int32
}

extension CDSearchHistory {
    @nonobjc
    public class func fetchRequest() -> NSFetchRequest<CDSearchHistory> {
        NSFetchRequest<CDSearchHistory>(entityName: "CDSearchHistory")
    }

    static func entityDescription() -> NSEntityDescription {
        let e = NSEntityDescription()
        e.name = "CDSearchHistory"
        e.managedObjectClassName = NSStringFromClass(CDSearchHistory.self)
        e.properties = [
            CoreDataStack.cdMakeAttribute(name: "query", type: .stringAttributeType),
            CoreDataStack.cdMakeAttribute(name: "timestamp", type: .dateAttributeType),
            CoreDataStack.cdMakeAttribute(name: "resultCount", type: .integer32AttributeType)
        ]
        return e
    }
}
