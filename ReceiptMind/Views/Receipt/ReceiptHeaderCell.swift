//
//  ReceiptHeaderCell.swift
//  ReceiptMind
//
//  Created by 권정근 on 7/2/25.
//

import UIKit

class ReceiptHeaderCell: UICollectionViewCell {
    
    
    // MARK: - Variable
    static let reuseIdentifier: String = "ReceiptHeaderCell"
    
    
    // MARK: - UI Component
    private let nameLabel: UILabel = UILabel()
    private let quantityLabel: UILabel = UILabel()
    private let priceLabel: UILabel = UILabel()
    private let etcLabel: UILabel = UILabel()
    
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .systemBackground
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Function
    private func setupUI() {
        let stack = UIStackView(arrangedSubviews: [nameLabel, quantityLabel, priceLabel])
        stack.axis = .horizontal
        stack.distribution = .fill
        stack.spacing = 4
        stack.alignment = .fill
        
        contentView.addSubview(stack)
        contentView.addSubview(etcLabel)
        
        stack.translatesAutoresizingMaskIntoConstraints = false
        etcLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            stack.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.8),
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            etcLabel.leadingAnchor.constraint(equalTo: stack.trailingAnchor, constant: 8),
            etcLabel.topAnchor.constraint(equalTo: stack.topAnchor, constant: 0),
            etcLabel.bottomAnchor.constraint(equalTo: stack.bottomAnchor, constant: 0),
            etcLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12)
        ])
        
        nameLabel.text = "상품명"
        quantityLabel.text = "수량"
        priceLabel.text = "사용금액"
        
        [nameLabel, quantityLabel, priceLabel].forEach {
            $0.textAlignment = .center
            $0.font = .boldSystemFont(ofSize: 14)
            $0.numberOfLines = 1
            $0.adjustsFontSizeToFitWidth = true
        }
        
        etcLabel.text = "비고"
        etcLabel.textAlignment = .center
        etcLabel.font = .boldSystemFont(ofSize: 14)
        
        nameLabel.widthAnchor.constraint(equalTo: stack.widthAnchor, multiplier: 0.55).isActive = true
        quantityLabel.widthAnchor.constraint(equalTo: stack.widthAnchor, multiplier: 0.15).isActive = true
        //priceLabel.widthAnchor.constraint(equalTo: stack.widthAnchor, multiplier: 0.15).isActive = true
    }
}
