//
//  ViewController.swift
//  ReceiptMind
//
//  Created by 권정근 on 6/28/25.
//

import UIKit
import Photos
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
    
    private var selectedDate: Date = Date()   // 기본값은 오늘
    
    
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
        view.layer.cornerRadius = 8
        return view
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.showsVerticalScrollIndicator = false
        tableView.backgroundColor = .systemBackground
        tableView.layer.cornerRadius = 8
        return tableView
    }()
    
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .secondarySystemBackground
        configureConstraints()
        configureNavigation()
        checkPhotoLibraryPermission()
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
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        view.addSubview(monthLabel)
        view.addSubview(calendarView)
        view.addSubview(tableView)
        
        monthLabel.translatesAutoresizingMaskIntoConstraints = false
        calendarView.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            monthLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            monthLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            
            calendarView.topAnchor.constraint(equalTo: monthLabel.safeAreaLayoutGuide.bottomAnchor, constant: 12),
            calendarView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            calendarView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            calendarView.heightAnchor.constraint(equalToConstant: 350),
            
            tableView.topAnchor.constraint(equalTo: calendarView.bottomAnchor, constant: 12),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12)
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
        self.selectedDate = date
        tableView.reloadData()   // 날짜가 바뀌면 테이블 갱신
    }
}


// MARK: - Extension: UITableViewDelegate, UITableViewDataSource
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .clear
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .systemBlue
        
        let formatter = DateFormatter()
        formatter.dateFormat = "M월 d일"
        label.text = "\(formatter.string(from: selectedDate)) 지출 내역"
        
        headerView.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            label.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
        ])
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "TEST"
        return cell
    }
}


// MARK: - Extension: Navigation Setting
extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    private func configureNavigation() {
        let addReceiptButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addReceipt))
        navigationItem.rightBarButtonItem = addReceiptButton
    }
    
    private func showCameraAndAlbum() {
        let alert = UIAlertController(title: "카메라 또는 앨범 선택", message: nil, preferredStyle: .actionSheet)
        
        let showCameraAction = UIAlertAction(title: "Camera", style: .default) { _ in
            print("카메라 선택")
            MediaPermissionManager.shared.checkAndRequestIfNeeded(.camera) { [weak self] granted in
                guard let self else { return }
                if granted {
                    self.openCamera()
                } else {
                    self.showPermissionAlert(title: "카메라 권한이 필요합니다.", message: "설정으로 이동하여 권한을 승인하세요")
                }
            }
            //self.openCamera()
        }
        
        let choosePhotoAction = UIAlertAction(title: "Photo Library", style: .default) { _ in
            print("사진첩 선택")
            MediaPermissionManager.shared.checkAndRequestIfNeeded(.album) { [weak self] granted in
                guard let self else { return }
                if granted {
                    print("사진첩을 선택헤서 사진첩으로 접근합니다.")
                } else {
                    self.showPermissionAlert(title: "사진첩 권한이 필요합니다.", message: "설정으로 이동하여 권한을 승인하세요")
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        alert.addAction(showCameraAction)
        alert.addAction(choosePhotoAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    private func openCamera() {
        let imagePicker = UIImagePickerController()
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.sourceType = .camera
            imagePicker.delegate = self
            present(imagePicker, animated: true, completion: nil)
        } else {
            print("카메라 접근 권한이 필요합니다.")
        }
    }
    
    @objc private func addReceipt() {
        self.showCameraAndAlbum()
    }
    
}


// MARK: - Extension: 카메라, 앨범 접근 권한 설정
extension ViewController {
    private func checkPhotoLibraryPermission() {
        
        MediaPermissionManager.shared.checkAndRequestIfNeeded(.album) { [weak self] granted in
            guard let self else { return }
            if granted {
                print("앨범 접근 승인")
            } else {
                print("앨범 접근 불허")
                self.showPermissionAlert(title: "앨범 접근이 필요합니다.", message: "설정에서 권한을 허용해주세요 ")
            }
        }
        
        MediaPermissionManager.shared.checkAndRequestIfNeeded(.camera) { [weak self] granted in
            guard let self else { return }
            if granted {
                print("카메라 접근 승인")
            } else {
                print("카메라 접근 불허")
                self.showPermissionAlert(title: "카메라 접근이 필요합니다.", message: "설정에서 권한을 허용해주세요 ")
            }
        }

    }
    
    func showPermissionAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "설정으로 이동", style: .default) { _ in
            guard let settingURL = URL(string: UIApplication.openSettingsURLString) else { return }
            UIApplication.shared.open(settingURL)
        })
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        present(alert, animated: true)
    }
}
