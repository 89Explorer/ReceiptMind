//
//  ReceiptRow.swift
//  ReceiptMind
//
//  Created by 권정근 on 7/1/25.
//

import Foundation
import UIKit


//struct ReceiptRow: Codable {
//    var id: String     // ex) "receiptID_receiptRowID"
//    var product: String
//    var count: Int
//    var price: Double
//}

class ReceiptRow {
    var id: String
    var product: String
    var count: Int
    var price: Double
    
    init(parentID: UUID, product: String, count: Int, price: Double) {
        self.id = "\(parentID.uuidString)_\(UUID().uuidString)"
        self.product = product
        self.count = count
        self.price = price
    }
}


class Receipt {
    var id: UUID
    var imagePath: String
    var place: String
    var date: Date
    var list: [ReceiptRow]
    var total: Double
    var memo: String
    
    init(id: UUID, imagePath: String, place: String, date: Date, list: [ReceiptRow],total: Double, memo: String) {
        self.id = id
        self.imagePath = imagePath
        self.place = place
        self.date = date
        self.list = list
        self.total = total
        self.memo = memo
    }
}
