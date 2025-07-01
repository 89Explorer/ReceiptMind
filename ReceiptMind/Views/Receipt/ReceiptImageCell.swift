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
        contentView.backgroundColor = .systemBackground
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
            receiptImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            receiptImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            receiptImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            receiptImage.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }
    
    func configure(with selectedReceipt: UIImage) {
        self.receiptImage.image = selectedReceipt
    }
}
