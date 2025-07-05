//
//  ReceiptEntity+CoreDataProperties.swift
//  ReceiptMind
//
//  Created by 권정근 on 7/4/25.
//
//

import Foundation
import CoreData


extension ReceiptEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ReceiptEntity> {
        return NSFetchRequest<ReceiptEntity>(entityName: "ReceiptEntity")
    }

    @NSManaged public var imagePath: String?
    @NSManaged public var place: String?
    @NSManaged public var date: Date?
    @NSManaged public var total: Double
    @NSManaged public var memo: String?
    @NSManaged public var receiptId: UUID?
    @NSManaged public var rows: NSSet?

}

// MARK: Generated accessors for rows
extension ReceiptEntity {

    @objc(addRowsObject:)
    @NSManaged public func addToRows(_ value: ReceiptRowEntity)

    @objc(removeRowsObject:)
    @NSManaged public func removeFromRows(_ value: ReceiptRowEntity)

    @objc(addRows:)
    @NSManaged public func addToRows(_ values: NSSet)

    @objc(removeRows:)
    @NSManaged public func removeFromRows(_ values: NSSet)

}
