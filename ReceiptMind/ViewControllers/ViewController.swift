//
//  ViewController.swift
//  ReceiptMind
//
//  Created by 권정근 on 6/28/25.
//

import UIKit
import JTAppleCalendar

class ViewController: UIViewController {
    
    
    // MARK: - Variable
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy MM dd"
        formatter.timeZone = .current
        formatter.locale = .current
        return formatter
    }()
    
    
    // MARK: - UI Component
    private let monthLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 24)
        label.textAlignment = .center
        label.textColor = .label
        return label
    }()
    
    private let calendarView: JTACMonthView = {
        let view = JTACMonthView()
        view.scrollDirection = .horizontal
        view.scrollingMode = .stopAtEachCalendarFrame  // 달 단위로 스크롤
        view.showsHorizontalScrollIndicator = false
        view.minimumLineSpacing = 0
        view.minimumInteritemSpacing = 0
        return view
    }()
    
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .secondarySystemBackground
        configureConstraints()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        calendarView.reloadData {
            self.calendarView.scrollToDate(Date(), animateScroll: false)
        }
    }
    
    
    // MARK: - Function
    private func configureConstraints() {
        calendarView.calendarDataSource = self
        calendarView.calendarDelegate = self
        calendarView.register(CalendarCell.self, forCellWithReuseIdentifier: CalendarCell.reuseIdentifier)
        
        view.addSubview(monthLabel)
        view.addSubview(calendarView)
        monthLabel.translatesAutoresizingMaskIntoConstraints = false
        calendarView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            
            monthLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            monthLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            
            calendarView.topAnchor.constraint(equalTo: monthLabel.safeAreaLayoutGuide.bottomAnchor, constant: 12),
            calendarView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            calendarView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            calendarView.heightAnchor.constraint(equalToConstant: 350)
        ])
    }
    
}


// MARK: - Extension: JTACMonthViewDataSource, JTACMonthViewDelegate
extension ViewController: JTACMonthViewDataSource, JTACMonthViewDelegate {
    
    // 셀 초기 생성 시 UI 구성
    func calendar(_ calendar: JTAppleCalendar.JTACMonthView, cellForItemAt date: Date, cellState: JTAppleCalendar.CellState, indexPath: IndexPath) -> JTAppleCalendar.JTACDayCell {
        guard let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: CalendarCell.reuseIdentifier, for: indexPath) as? CalendarCell else { return JTAppleCalendar.JTACDayCell() }
        cell.configure(with: cellState.text,
                       textColor: {
            let weekday = Calendar.current.component(.weekday, from: date)
            switch weekday {
            case 1: return UIColor.systemRed
            case 7: return UIColor.systemBlue
            default: return .label
            }
        }(),
                       isToday: Calendar.current.isDateInToday(date)
        )
        return cell
    }
    
    // 셀 재사용 시 스타일 초기화 및 조건부 UI 적용
    func calendar(_ calendar: JTAppleCalendar.JTACMonthView, willDisplay cell: JTAppleCalendar.JTACDayCell, forItemAt date: Date, cellState: JTAppleCalendar.CellState, indexPath: IndexPath) {
//        guard let myCell = cell as? CalendarCell else { return }
//        
//        // 기본 날짜 표시
//        myCell.configure(with: cellState.text)
//        
//        let weekday = Calendar.current.component(.weekday, from: date)
//        switch weekday {
//        case 1: // 일요일
//            myCell.label.textColor = .systemRed
//        case 7: // 토요일
//            myCell.label.textColor = .systemBlue
//        default:
//            myCell.label.textColor = .label
//        }
//        
//        // 오늘 날짜 강조
//        if Calendar.current.isDateInToday(date) {
//            myCell.layer.borderColor = UIColor.systemRed.cgColor
//            myCell.layer.borderWidth = 2
//        } else {
//            myCell.layer.borderWidth = 0
//        }
    }
    
    // 날짜 범위 지정
    func configureCalendar(_ calendar: JTAppleCalendar.JTACMonthView) -> JTAppleCalendar.ConfigurationParameters {
        let startDate = dateFormatter.date(from: "2020 01 01")!
        let endDate = dateFormatter.date(from: "2100 12 31")!
        return ConfigurationParameters(startDate: startDate, endDate: endDate)
    }
    
    // 스크롤할 때마다 현재 월의 날짜를 업데이트
    func calendar(_ calendar: JTACMonthView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        guard let date = visibleDates.monthDates.first?.date else { return }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 MM월"
        monthLabel.text = formatter.string(from: date)
    }
    
    func calendar(_ calendar: JTACMonthView, didSelectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) {
        let selectedDates = calendar.selectedDates
        print("Selected dates: \(selectedDates)")
    }
}

