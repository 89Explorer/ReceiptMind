//
//  ReceiptManager.swift
//  ReceiptMind
//
//  Created by 권정근 on 7/4/25.
//

import Foundation
import CoreData
import UIKit
import Combine

class ReceiptManager {
    
    // MARK: - Variable
    static let shared = ReceiptManager()
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private let storageManager = ReceiptFileManager.shared
    
    
    // MARK: - Create
    func createReceipt(_ receipt: Receipt, image: UIImage) -> AnyPublisher<Receipt, Error> {
        return Future { [weak self] promise in
            guard let self = self else { return }
            
            // 1) 이미지들을 FileManager에 저장
            guard let savedPath = self.storageManager.saveImage(image: image, receiptID: receipt.id.uuidString) else {
                print("❌ 이미지 저장 실패")
                promise(.failure(NSError(domain: "ReceiptImageSaveError", code: 1)))
                return
                
            }
            
            // 2) 저장된 이미지 경로를 receipt.imagePath에 설정
            var updatedReceipt = receipt
            updatedReceipt.imagePath = savedPath
            
            // 3) Core Data 객체 생성
            let receiptModel = ReceiptEntity(context: self.context)
            receiptModel.receiptId = updatedReceipt.id
            receiptModel.place = updatedReceipt.place
            receiptModel.date = updatedReceipt.date
            receiptModel.memo = updatedReceipt.memo
            receiptModel.total = updatedReceipt.total
            receiptModel.imagePath = savedPath
            
            // 4) ReceiptRowEntity 저장 및 관계 연결
            for row in updatedReceipt.list {
                let rowEntity = ReceiptEntity(context: self.context)
                rowEntity.rowId = row.id
                rowEntity.product = row.product
                rowEntity.count = Int64(row.count)
                rowEntity.price = row.price
                rowEntity.receipt = receiptModel
            }
            
            // ✅ 디버깅 로그 시작
            print("🧾 CoreDataManager: 저장할 Receipt 정보 확인")
            print("   - ID: \(updatedReceipt.id)")
            print("   - 장소: \(updatedReceipt.place)")
            print("   - 날짜: \(updatedReceipt.date)")
            print("   - 메모: \(updatedReceipt.memo)")
            print("   - 총액: \(updatedReceipt.total)")
            print("   - 이미지 경로: \(updatedReceipt.imagePath)")
            print("   - 사용내역: \(updatedReceipt.list.count)개")
            
            for (index, row) in updatedReceipt.list.enumerated() {
                print("     • \(index + 1)번 항목: 상품명=\(row.product), 수량=\(row.count), 가격=\(row.price)")
            }
            
            do {
                try self.context.save()
                print("✅ Core Data 저장 성공!")
                promise(.success(updatedReceipt))
            } catch {
                print("❌ Core Data 저장 실패: \(error.localizedDescription)")
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
    
    
}
