//
//  ReceiptImageCell.swift
//  ReceiptMind
//
//  Created by 권정근 on 6/30/25.
//

import UIKit

class ReceiptImageCell: UITableViewCell {
    
    // MARK: - Variable
    static let reuseIdentifier: String = "ReceiptImageCell"
    
    
    // MARK: - UI Component
    private var receiptImage: UIImageView = UIImageView()
    
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        contentView.backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    // MARK: - Function
    private func setupUI() {
        receiptImage.contentMode = .scaleAspectFit
        receiptImage.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(receiptImage)
        
        NSLayoutConstraint.activate([
            receiptImage.topAnchor.constraint(equalTo: contentView.topAnchor),
            receiptImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            receiptImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            receiptImage.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    func configure(with selectedReceipt: UIImage) {
        self.receiptImage.image = selectedReceipt
    }
}
