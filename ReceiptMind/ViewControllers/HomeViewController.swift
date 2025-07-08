//
//  HomeViewController.swift
//  ReceiptMind
//
//  Created by 권정근 on 7/8/25.
//

import UIKit

class HomeViewController: UIViewController  {
    
    
    // MARK: - Variable
    private var selectedDate: Date = Date()
    private var dummyData: [HomeTableModel] = [
        HomeTableModel(date: Date(), place: "GS 편의점, 가정점", cost: 13400, category: "간식"),
        HomeTableModel(date: Date(), place: "CU 편의점, 루원점", cost: 224500, category: "식료품"),
        HomeTableModel(
            date: Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date(),
            place: "스타벅스 강남점",
            cost: 5900,
            category: "카페"
        ),
        HomeTableModel(
            date: Calendar.current.date(byAdding: .day, value: 12, to: Date()) ?? Date(),
            place: "스타벅스 강남점",
            cost: 15900,
            category: "카페"
        ),
        
    ]
    private var filteredData: [HomeTableModel] {
        dummyData.filter {
            Calendar.current.isDate($0.date, inSameDayAs: selectedDate)
        }
    }
    
    
    // MARK: - UI Component
    private let calendarView = UICalendarView()
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemFill
        setupUI()
        configureNavigation()
    }
    
    
    // MARK: - Function
    private func setupUI() {
        calendarView.locale = Locale(identifier: "ko")
        calendarView.layer.cornerRadius = 24
        calendarView.backgroundColor = .clear
        calendarView.calendar = .current
        calendarView.delegate = self
        
        // ✅ 단일 날짜 선택 동작 지정
        let selection = UICalendarSelectionSingleDate(delegate: self)
        calendarView.selectionBehavior = selection
        
        // 📌 초기 선택된 날짜 설정
        let today = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        selection.setSelected(today, animated: false)
        
        // ✅ calendarView는 직접 frame 지정해야 tableHeaderView에 적용됨
        calendarView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 500)
        tableView.tableHeaderView = calendarView
        
        
        tableView.backgroundColor = .systemYellow
        tableView.layer.cornerRadius = 24
        tableView.showsVerticalScrollIndicator = false
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(HomeTableCell.self, forCellReuseIdentifier: HomeTableCell.reuseIdentifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
    }
    
}


// MARK: - Extension: 네비게이션 셋팅
extension HomeViewController {
    private func configureNavigation() {
        let titleStack = UIStackView()
        titleStack.axis = .horizontal
        titleStack.spacing = 6
        titleStack.alignment = .center

        // 🏷️ 타이틀 라벨
        let titleLabel = UILabel()
        titleLabel.text = "지출내역"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.textColor = .systemBackground

        // 📅 아이콘
        let iconImageView = UIImageView(image: UIImage(systemName: "calendar"))
        iconImageView.tintColor = .systemBackground
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.widthAnchor.constraint(equalToConstant: 20).isActive = true
        iconImageView.heightAnchor.constraint(equalToConstant: 20).isActive = true

        titleStack.addArrangedSubview(iconImageView)
        titleStack.addArrangedSubview(titleLabel)

        navigationItem.titleView = titleStack
    }
}



// MARK: - Extension: UITableViewDataSource, UITableViewDelegate
extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    //    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    //        let headerView = UIView()
    //        headerView.backgroundColor = .systemBackground
    //        let bezierPath = UIBezierPath(roundedRect: view.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 12, height: 12))
    //        let maskLayer = CAShapeLayer()
    //
    //        maskLayer.path = bezierPath.cgPath
    //        headerView.layer.mask = maskLayer
    //
    //        let label = UILabel()
    //        label.translatesAutoresizingMaskIntoConstraints = false
    //        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
    //        label.textColor = .systemBlue
    //
    //        let formatter = DateFormatter()
    //        formatter.dateFormat = "M월 d일"
    //        label.text = "\(formatter.string(from: selectedDate)) 지출 내역"
    //
    //        headerView.addSubview(label)
    //        NSLayoutConstraint.activate([
    //            label.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
    //            label.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
    //        ])
    //
    //        return headerView
    //    }
    
    //    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    //        return 44
    //    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HomeTableCell.reuseIdentifier, for: indexPath) as? HomeTableCell else { return HomeTableCell() }
        let item = filteredData[indexPath.row]
        cell.configure(with: item)
        return cell
    }
}


// MARK: - Extension: UICalendarViewDelegate
extension HomeViewController: UICalendarViewDelegate, UICalendarSelectionSingleDateDelegate {
    
    func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
        guard let selected = dateComponents?.date else { return }
        selectedDate = selected
        print("📅 선택된 날짜: \(selected)")
        tableView.reloadData()
    }
    
    func calendarView(_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
        let calendar = Calendar.current
        
        // 해당 날짜와 일치하는 모든 항목 필터링
        let filtered = dummyData.filter {
            calendar.isDate($0.date, inSameDayAs: calendar.date(from: dateComponents) ?? Date())
        }
        
        // 지출 합산
        let totalCost = filtered.reduce(0) { $0 + $1.cost }
        
        guard totalCost > 0 else { return nil } // 값이 없으면 데코 표시 안 함
        
        // 💡 라벨로 표시할 UILabel 생성
        let label = UILabel()
        label.text = "₩\(Int(totalCost))"
        label.font = .systemFont(ofSize: 8, weight: .regular)
        label.textColor = .label
        //label.backgroundColor = .systemBlue
        label.textAlignment = .center
        
        // 크기 조절
        label.frame = CGRect(x: 0, y: 0, width: 40, height: 20)
        
        return .customView {
            return label
        }
    }
}

