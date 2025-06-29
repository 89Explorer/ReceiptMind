//
//  CalendarCell.swift
//  ReceiptMind
//
//  Created by 권정근 on 6/28/25.
//

import UIKit
import JTAppleCalendar

class CalendarCell: JTACDayCell {
    
    static let reuseIdentifier: String = "CalendarCell"
    
    
    // MARK: - UI Component
    let label: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        label.textAlignment = .center
        label.textColor = .label
        return label
    }()
    
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        configureConstraints()
    }
    
    @MainActor required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Function
    private func configureConstraints() {
        contentView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8)
        ])
    }
    
    func configure(with date: String,
                   textColor: UIColor = .label,
                   isToday: Bool = false) {
        label.text = date
        label.textColor = textColor
        
        if isToday {
            layer.borderColor = UIColor.systemRed.cgColor
            layer.cornerRadius = 8
            layer.borderWidth = 2
        } else {
            layer.borderWidth = 0
            layer.borderColor = nil
        }
    }
    
}
