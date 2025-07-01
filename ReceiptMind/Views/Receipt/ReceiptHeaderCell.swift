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
        stack.distribution = .fillEqually
        contentView.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stack.topAnchor.constraint(equalTo: contentView.topAnchor),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        nameLabel.text = "상품명"
        quantityLabel.text = "수량"
        priceLabel.text = "금액"
        [nameLabel, quantityLabel, priceLabel].forEach {
            $0.textAlignment = .center
            $0.font = .boldSystemFont(ofSize: 14)
        }
    }
}
