//
//  ReceiptRowEntity+CoreDataProperties.swift
//  ReceiptMind
//
//  Created by 권정근 on 7/4/25.
//
//

import Foundation
import CoreData


extension ReceiptRowEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ReceiptRowEntity> {
        return NSFetchRequest<ReceiptRowEntity>(entityName: "ReceiptRowEntity")
    }

    @NSManaged public var product: String?
    @NSManaged public var count: Int64
    @NSManaged public var price: Double
    @NSManaged public var rowId: String?
    @NSManaged public var receipt: ReceiptEntity?

}

extension ReceiptRowEntity : Identifiable {

}
