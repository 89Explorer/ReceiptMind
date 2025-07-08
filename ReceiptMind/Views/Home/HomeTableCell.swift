//
//  HomeTableCell.swift
//  ReceiptMind
//
//  Created by 권정근 on 7/8/25.
//

import UIKit

class HomeTableCell: UITableViewCell {
    
    
    // MARK: - Variable
    static let reuseIdentifier: String = "HomeTableCell"
    
    
    // MARK: - UI Component
    private let dateLabel: UILabel = UILabel()
    private let placeLabel: UILabel = UILabel()
    private let expenseLabel: UILabel = UILabel()
    private let categoryLabel: UILabel = UILabel()
    
    
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
        dateLabel.text = "2025-07-09 02:11:22"
        dateLabel.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        dateLabel.textColor = .label
        
        placeLabel.text = "GS 편의점 가정점"
        placeLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        placeLabel.textColor = .label
        placeLabel.textAlignment = .right
        
        expenseLabel.text = "₩ 3,400"
        expenseLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        expenseLabel.textColor = .systemBlue
        expenseLabel.textAlignment = .right
        
        categoryLabel.text = "간식"
        categoryLabel.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        categoryLabel.textColor = .label
        
        let topStack = UIStackView(arrangedSubviews: [dateLabel, placeLabel])
        topStack.axis = .horizontal
        topStack.distribution = .fillEqually
        
        let bottomStack = UIStackView(arrangedSubviews: [categoryLabel, expenseLabel])
        bottomStack.axis = .horizontal
        bottomStack.distribution = .fillEqually
        
        let mainStack = UIStackView(arrangedSubviews: [topStack, bottomStack])
        mainStack.axis = .vertical
        mainStack.spacing = 8
        
        contentView.addSubview(mainStack)
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        

        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            mainStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            mainStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    
    func configure(with item: HomeTableModel) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateString = dateFormatter.string(from: item.date)
        
        dateLabel.text = dateString
        placeLabel.text = item.place
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        if let formattedCost = numberFormatter.string(from: NSNumber(value: item.cost)) {
            expenseLabel.text = "₩ \(formattedCost)"
        }
        categoryLabel.text = item.category
        
    }
}
