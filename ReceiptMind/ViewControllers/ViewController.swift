//
//  ViewController.swift
//  ReceiptMind
//
//  Created by 권정근 on 6/28/25.
//

import UIKit
import PhotosUI
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
    func calendar(_ calendar: JTACMonthView,
                  cellForItemAt date: Date,
                  cellState: CellState,
                  indexPath: IndexPath) -> JTACDayCell {
        
        guard let cell = calendar.dequeueReusableJTAppleCell(
            withReuseIdentifier: CalendarCell.reuseIdentifier,
            for: indexPath) as? CalendarCell else {
            return JTACDayCell()
        }

        let weekdayIndex = Calendar.current.component(.weekday, from: date)
        let weekdaySymbol = Calendar.current.shortStandaloneWeekdaySymbols[weekdayIndex - 1] // 일~토

        // 색상 분기: 주말 + 평일 + 비속한 날짜 처리
        var textColor: UIColor = .label
        switch weekdayIndex {
        case 1: textColor = .systemRed     // 일요일
        case 7: textColor = .systemBlue    // 토요일
        default: textColor = .label
        }

        if cellState.dateBelongsTo != .thisMonth {
            textColor = .lightGray
        }

        cell.configure(
            with: cellState.text,
            weekdayText: weekdaySymbol,
            textColor: textColor,
            isToday: Calendar.current.isDateInToday(date),
            cost: nil
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
//    func configureCalendar(_ calendar: JTAppleCalendar.JTACMonthView) -> JTAppleCalendar.ConfigurationParameters {
//        let startDate = dateFormatter.date(from: "2020 01 01")!
//        let endDate = dateFormatter.date(from: "2100 12 31")!
//        
//        let parameters = ConfigurationParameters(
//            startDate: startDate,
//            endDate: endDate,
//            calendar: Calendar.current,
//            hasStrictBoundaries: true
//        )
//        
//        return parameters
//    }
    
    func configureCalendar(_ calendar: JTACMonthView) -> ConfigurationParameters {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy MM dd"

        let startDate = formatter.date(from: "2020 01 01")!
        let endDate = formatter.date(from: "2030 12 31")!

        return ConfigurationParameters(
            startDate: startDate,
            endDate: endDate,
            numberOfRows: 6, // 달력은 항상 6줄로
            calendar: Calendar.current,
            generateInDates: .forAllMonths,   // ✅ 전달 말일 표시
            generateOutDates: .tillEndOfGrid, // ✅ 다음달 시작일 표시
            firstDayOfWeek: .sunday,
            hasStrictBoundaries: true         // ✅ 한 달씩 정확히 스크롤
        )
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


// MARK: - Extension: 카메라 및 앨범 실행 부분 (네비게이션)
extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate, PHPickerViewControllerDelegate {
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
                    self.presentPhotoPicker()
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
    
    // 카메라로 찍은 이미지 사용
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        guard let image = info[.originalImage] as? UIImage else { return }
        
        //        let receiptVC = ReceiptViewController(receiptImage: image)
        //        receiptVC.modalPresentationStyle = .fullScreen
        //        self.present(receiptVC, animated: true)
        
        DispatchQueue.main.async {
            let receiptVC = ReceiptViewController(receiptImage: image)
            let nav = UINavigationController(rootViewController: receiptVC)
            nav.modalPresentationStyle = .fullScreen
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first,
               let rootVC = window.rootViewController {
                rootVC.present(nav, animated: true)
            }
        }
    }
    
    // 사진첩에서 사진선택 및 설정하는 함수
    func presentPhotoPicker() {
        var config = PHPickerConfiguration()
        config.selectionLimit = 1
        config.filter = .images
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    // 사진첩에서 선택하나 후 호출되는 함수
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        guard let result = results.first,
              result.itemProvider.canLoadObject(ofClass: UIImage.self) else { return }
        
        result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
            guard let self, let image = object as? UIImage else { return }
            
            DispatchQueue.main.async {
                let receiptVC = ReceiptViewController(receiptImage: image)
                let nav = UINavigationController(rootViewController: receiptVC)
                nav.modalPresentationStyle = .fullScreen
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = windowScene.windows.first,
                   let rootVC = window.rootViewController {
                    rootVC.present(nav, animated: true)
                }
            }
            
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
