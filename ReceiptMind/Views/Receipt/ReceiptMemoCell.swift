//
//  ReceiptMemoCell.swift
//  ReceiptMind
//
//  Created by 권정근 on 7/1/25.
//

import UIKit

class ReceiptMemoCell: UITableViewCell {
    
    // MARK: - Variable
    static let reuseIdentifier: String = "ReceiptMemoCell"
    private let minHeight: CGFloat = 200
    
    weak var delegate: ReceiptMemoCellDelegate?
    
    
    // MARK: - UI Component
    private let textView: UITextView = UITextView()
    
    
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
    private func setupUI() {
        textView.font = .systemFont(ofSize: 12)
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.label.cgColor
        textView.textColor = .label
        textView.layer.cornerRadius = 8
        textView.backgroundColor = .secondarySystemBackground
        textView.textContainer.lineFragmentPadding = 12
        let heightConstraint = textView.heightAnchor.constraint(greaterThanOrEqualToConstant: minHeight)
        heightConstraint.priority = .defaultHigh
        heightConstraint.isActive = true
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(textView)
        
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            textView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            textView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            textView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8)
        ])
    }
    
    func configure(with text: String, delegate: ReceiptMemoCellDelegate?) {
        textView.text = text
        textView.delegate = self
        self.delegate = delegate
    }
}


// MARK: - Protocol
protocol ReceiptMemoCellDelegate: AnyObject {
    func didUpdateMemo(_ memo: String)
}


// MARK: - Extension: UITextViewDelegate
extension ReceiptMemoCell: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        delegate?.didUpdateMemo(textView.text)
    }
}
