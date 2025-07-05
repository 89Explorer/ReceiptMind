//
//  ReceiptViewModel.swift
//  ReceiptMind
//
//  Created by 권정근 on 7/4/25.
//

import Foundation
import Combine
import CoreData
import UIKit

class ReceiptViewModel {
    
    // MARK: - Variable
    @Published var receiptItem: Receipt = Receipt(
        id: UUID(),
        imagePath: "",
        place: "",
        date: Date(),
        list: [],
        total: 0.0,
        memo: "")
    @Published var receiptItems: [Receipt] = []
    
    @Published var errorMessage: String?
    
    private var cancellables: Set<AnyCancellable> = []
    let coredataManager = ReceiptManager.shared
    
    
    // MARK: - Function: Create
    func createReceipt(_ receipt: Receipt, _ image: UIImage)
    {
        print("😎 ReceiptViewModel: 새로운 영수증 저장 요청")
        
        coredataManager.createReceipt(receipt, image: image)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    print("✅ ReceiptViewModel: 영수증 저장이 완료되었습니다. ")
                case .failure(let error):
                    print("❌ ReceiptViewModel: 저장 실패: \(error.localizedDescription)")
                    self.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] receiptItem in
                print("👍 ReceiptViewMode: 저장된 영수증 확인")
                print("   - ID: \(receiptItem.id)")
                print("   - 장소: \(receiptItem.place)")
                print("   - 날짜: \(receiptItem.date)")
                print("   - 메모: \(receiptItem.memo)")
                print("   - 총액: \(receiptItem.total)")
                print("   - 이미지 경로: \(receiptItem.imagePath)")
                print("   - 사용내역: \(receiptItem.list.count)개")
                
                for (index, row) in receiptItem.list.enumerated() {
                    print("     • \(index + 1)번 항목: 상품명=\(row.product), 수량=\(row.count), 가격=\(row.price)")
                }
                self?.receiptItem = receiptItem
                self?.receiptItems.append(receiptItem)
                print("👍 ReceiptViewModel: receiptItem 배열 업데이트 완료")
            }
            .store(in: &cancellables)
        
    }
}
