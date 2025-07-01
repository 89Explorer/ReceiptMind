//
//  ReceiptRowCell.swift
//  ReceiptMind
//
//  Created by 권정근 on 7/1/25.
//

import UIKit

class ReceiptRowCell: UICollectionViewCell {
    
    
    // MARK: - Variable
    static let reuseIdentifier: String = "ReceiptRowCell"
    
    
    // MARK: - UI Component
    let nameField: UITextField = UITextField()
    let quantityField: UITextField = UITextField()
    let priceField: UITextField = UITextField()
    
    
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
        let stack = UIStackView(arrangedSubviews: [nameField, quantityField, priceField])
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
        [nameField, quantityField, priceField].forEach {
            $0.borderStyle = .roundedRect
            $0.placeholder = "입력"
            $0.backgroundColor = .secondarySystemBackground
            $0.textAlignment = .center
            $0.font = .systemFont(ofSize: 14)
        }
    }
}
