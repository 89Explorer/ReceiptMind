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
    weak var delegate: ReceiptRowCellDelegate?
    
    
    // MARK: - UI Component
    var nameField: UITextField = UITextField()
    var quantityField: UITextField = UITextField()
    var priceField: UITextField = UITextField()
    var deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("삭제", for: .normal)
        button.setTitleColor(.systemRed, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        button.addTarget(self, action: #selector(didTapDelete), for: .touchUpInside)
        return button
    }()
    
    
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
        stack.distribution = .fill
        stack.spacing = 4
        stack.alignment = .fill
        
        contentView.addSubview(stack)
        contentView.addSubview(deleteButton)
        
        stack.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            stack.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.8),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0),
            
            deleteButton.leadingAnchor.constraint(equalTo: stack.trailingAnchor, constant: 8),
            deleteButton.topAnchor.constraint(equalTo: stack.topAnchor, constant: 0),
            deleteButton.bottomAnchor.constraint(equalTo: stack.bottomAnchor, constant: 0),
            deleteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12)
        ])
        
        [nameField, quantityField, priceField].forEach {
            $0.placeholder = "입력"
            $0.backgroundColor = .secondarySystemBackground
            $0.textAlignment = .center
            $0.font = .systemFont(ofSize: 14)
            $0.layer.borderWidth = 1
            $0.layer.cornerRadius = 8
            $0.textColor = .label
        }
        
        // 👉 비율 제약 (stack 기준)
        nameField.widthAnchor.constraint(equalTo: stack.widthAnchor, multiplier: 0.55).isActive = true
        quantityField.widthAnchor.constraint(equalTo: stack.widthAnchor, multiplier: 0.15).isActive = true
        //priceField.widthAnchor.constraint(equalTo: stack.widthAnchor, multiplier: 0.25).isActive = true
    }
    
    
    // MARK: - Action Method
    @objc private func didTapDelete() {
        delegate?.didTapDelete(in: self)
    }
}


// MARK: - Protocol
protocol ReceiptRowCellDelegate: AnyObject {
    func didTapDelete(in cell: ReceiptRowCell)
}
