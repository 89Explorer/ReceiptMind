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
    
    let label = UILabel()              // 날짜 (1, 2, 3 ...)
    let weekdayLabel = UILabel()      // 요일 (일, 월, ...)
    let costLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        let stack = UIStackView(arrangedSubviews: [weekdayLabel, label, costLabel])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 4

        contentView.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])

        label.font = .systemFont(ofSize: 16)
        weekdayLabel.font = .systemFont(ofSize: 12)
        weekdayLabel.textColor = .secondaryLabel
        costLabel.font = .systemFont(ofSize: 10)
        costLabel.textColor = .label
    }

    func configure(with dateText: String, weekdayText: String, textColor: UIColor, isToday: Bool, cost: String?) {
        label.text = dateText
        weekdayLabel.text = weekdayText
        label.textColor = textColor
        costLabel.text = cost ?? "0원"
        if isToday {
            contentView.backgroundColor = UIColor.systemYellow.withAlphaComponent(0.3)
            contentView.layer.cornerRadius = 8
        } else {
            contentView.backgroundColor = .clear
        }
    }
}

