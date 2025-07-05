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
    weak var delegate: ReceiptInputDelegate?
    private var sectionTag: Int = 0
    
    
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
        commonTextField.layer.borderColor = UIColor.label.cgColor
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
    
    func configure(with text: String, delegate: ReceiptInputDelegate?, tag: Int) {
        commonTextField.text = text
        self.delegate = delegate
        self.sectionTag = tag
        commonTextField.delegate = self
    }
}


// MARK: - Extension: UITextFieldDelegate
extension ReceiptCommonCell: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        delegate?.didUpdateText(textField.text ?? "", forSection: sectionTag)
    }
}


// MARK: - Protocol
protocol ReceiptInputDelegate: AnyObject {
    func didUpdateText(_ text: String, forSection section: Int)
}
