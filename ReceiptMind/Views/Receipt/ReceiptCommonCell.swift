//
//  ReceiptCommonCell.swift
//  ReceiptMind
//
//  Created by 권정근 on 7/1/25.
//

import UIKit

class ReceiptCommonCell: UITableViewCell {
    
    // MARK: - Variable
    static let reuseIdentifier: String = "ReceiptCommonCell"
    private let minHeight: CGFloat = 44
    
    
    
    // MARK: - UI Component
    private let commonTextField: UITextField = UITextField()

    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .systemBackground
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Function
    func setupUI() {
        commonTextField.placeholder = "Enter Text"
        commonTextField.textColor = .label
        commonTextField.layer.borderWidth = 1
        commonTextField.layer.cornerRadius = 8
        commonTextField.backgroundColor = .secondarySystemBackground
        commonTextField.addLeftPadding()
        commonTextField.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        
        let heightConstraint = commonTextField.heightAnchor.constraint(greaterThanOrEqualToConstant: minHeight)
        heightConstraint.priority = .defaultHigh
        heightConstraint.isActive = true
        commonTextField.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(commonTextField)
        
        NSLayoutConstraint.activate([
            commonTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            commonTextField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            commonTextField.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            commonTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8)
        ])
    }
    
    func configure(with text: String, delegate: UITextFieldDelegate?, tag: Int) {
        commonTextField.text = text
        commonTextField.delegate = delegate
        commonTextField.tag = tag
    }
}
