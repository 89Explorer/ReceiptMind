//
//  ReceiptViewController.swift
//  ReceiptMind
//
//  Created by 권정근 on 6/30/25.
//

import UIKit
import Vision

class ReceiptViewController: UIViewController {
    
    
    // MARK: - Variable
    private let receiptImage: UIImage
    private let sectionTitle: [String] = ["영수증 사진", "지출 장소", "지출 날짜", "영수증 내역", "최종 금액", "메모"]
    private var receiptData: String = ""
    
    
    // 키보드 위치
    private var currentKeyboardHeight: CGFloat?
    
    // MARK: - UI Component
    private let tableView: UITableView = UITableView(frame: .zero, style: .insetGrouped)
    
    
    // MARK: - Init
    init(receiptImage: UIImage) {
        self.receiptImage = receiptImage
        super.init(nibName: nil, bundle: nil)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .secondarySystemBackground
        setupUI()
        configureNavigation()
        hideKeyboardWhenTappedAround()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        showLoadingIndicator()
        registerKeyboardNotification()
        
        performOCR(on: receiptImage) { [weak self] lines in
            DispatchQueue.main.async {
                self?.hideLoadingIndicator()
                self?.tableView.reloadData()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
    }
    
    
    // MARK: - Function
    private func setupUI() {
        tableView.showsLargeContentViewer = false
        tableView.backgroundColor = .systemBackground
        tableView.layer.cornerRadius = 8
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 300
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(ReceiptImageCell.self, forCellReuseIdentifier: ReceiptImageCell.reuseIdentifier)
        tableView.register(ReceiptCommonCell.self, forCellReuseIdentifier: ReceiptCommonCell.reuseIdentifier)
        tableView.register(ReceiptMemoCell.self, forCellReuseIdentifier: ReceiptMemoCell.reuseIdentifier)
        tableView.register(ReceiptBreakdownCell.self, forCellReuseIdentifier: ReceiptBreakdownCell.reuseIdentifier)
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12)
        ])
    }
    
    func showLoadingIndicator() {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .systemBlue
        indicator.center = view.center
        indicator.tag = 999
        view.addSubview(indicator)
        indicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
        if let indicator = view.viewWithTag(999) as? UIActivityIndicatorView {
            indicator.stopAnimating()
            indicator.removeFromSuperview()
        }
    }
}


// MARK: - Extension: 네비게이션 부분 설정
extension ReceiptViewController {
    private func configureNavigation() {
        title = "지출내역"
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(dismissSelf))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addReceipt))
    }
    
    @objc private func dismissSelf() {
        dismiss(animated: true)
    }
    
    @objc private func addReceipt() {
        print("addReceipt - called")
    }
}


// MARK: - Extension: UITableViewDelegate, UITableViewDataSource
extension ReceiptViewController: UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitle.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .clear
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .systemBlue
        label.text = sectionTitle[section]
        
        let separator = UIView()
        separator.backgroundColor = .lightGray
        separator.translatesAutoresizingMaskIntoConstraints = false
        
        headerView.addSubview(separator)
        headerView.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            label.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            separator.heightAnchor.constraint(equalToConstant: 1),
            separator.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            separator.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            separator.bottomAnchor.constraint(equalTo: headerView.bottomAnchor)
        ])
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let sectionIndex = indexPath.section
        
        switch sectionIndex {
        case 0:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ReceiptImageCell.reuseIdentifier, for: indexPath) as? ReceiptImageCell else { return ReceiptImageCell() }
            cell.configure(with: receiptImage)
            cell.selectionStyle = .none
            return cell
        case 1:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ReceiptCommonCell.reuseIdentifier, for: indexPath) as? ReceiptCommonCell else { return ReceiptCommonCell() }
            let address = extractAddress(from: receiptData) ?? ""
            cell.configure(with: address, delegate: self, tag: indexPath.section)
            cell.selectionStyle = .none
            return cell
        case 2:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ReceiptCommonCell.reuseIdentifier, for: indexPath) as? ReceiptCommonCell else { return ReceiptCommonCell() }
            let date = extractDate(from: receiptData) ?? Date()
            let extracted = formatDateToKorean(date)
            cell.configure(with: extracted, delegate: self, tag: indexPath.section)
            cell.selectionStyle = .none
            return cell
        case 3:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ReceiptBreakdownCell.reuseIdentifier, for: indexPath) as? ReceiptBreakdownCell else { return ReceiptBreakdownCell() }
            let items = extractItems(from: receiptData)
            cell.configure(with: items)
            return cell
        case 4:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ReceiptCommonCell.reuseIdentifier, for: indexPath) as? ReceiptCommonCell else { return ReceiptCommonCell() }
            cell.configure(with: "", delegate: self, tag: indexPath.section)
            cell.selectionStyle = .none
            return cell
            
        case 5:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ReceiptMemoCell.reuseIdentifier, for: indexPath) as? ReceiptMemoCell else { return ReceiptMemoCell() }
            
            return cell
            
        default:
            return UITableViewCell()
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 400
        case 1,2,4:
            return 60
        default:
            return UITableView.automaticDimension
        }
    }
    
    //    func textFieldDidBeginEditing(_ textField: UITextField) {
    //        guard let cell = textField.superview(of: UITableViewCell.self),
    //              let indexPath = tableView.indexPath(for: cell) else {
    //            return
    //        }
    //        switch indexPath.section {
    //        case 1:
    //            tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
    //        case 2:
    //            tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    //        default:
    //            break
    //        }
    //    }
    
    //    func textFieldDidBeginEditing(_ textField: UITextField) {
    //        guard let window = view.window,
    //              let cell = textField.superview(of: UITableViewCell.self),
    //              let indexPath = tableView.indexPath(for: cell) else {
    //            return
    //        }
    //
    //        // 텍스트필드의 위치를 기준으로 계산
    //        let textFieldFrameInView = textField.convert(textField.bounds, to: window)
    //
    //        // 키보드 높이 가져오기 (추적 중이던 값을 사용하거나 고정값 사용)
    //        let keyboardHeight = currentKeyboardHeight ?? 300  // 임시값 혹은 Noti에서 추적한 값 사용
    //
    //        // 키보드 위 여유 거리
    //        let spacing: CGFloat = 32
    //
    //        // 텍스트필드의 bottom 위치가 keyboard top 위로 올라오게끔 offset 계산
    //        let keyboardTop = window.bounds.height - keyboardHeight
    //        let overlap = textFieldFrameInView.maxY + spacing - keyboardTop
    //
    //        if overlap > 0 {
    //            // 현재 contentOffset을 조정해서 overlap만큼 위로 올림
    //            var offset = tableView.contentOffset
    //            offset.y += overlap
    //            tableView.setContentOffset(offset, animated: true)
    //        }
    //    }
}


// MARK: - Extension: OCR 셋팅
extension ReceiptViewController {
    func performOCR(on image: UIImage, completion: @escaping ([String]) -> Void) {
        guard let cgImage = image.cgImage else {
            print("❌ [OCR] UIImage → CGImage 변환 실패")
            completion([])
            return
        }
        let reqeustHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        let request = VNRecognizeTextRequest { (reqeust, error) in
            if let error = error {
                print("❌ [OCR] 텍스트 인식 실패:", error.localizedDescription)
                completion([])
                return
            }
            
            guard let observations = reqeust.results as? [VNRecognizedTextObservation] else {
                print("⚠️ [OCR] 결과를 VNRecognizedTextObservation 배열로 캐스팅 실패")
                completion([])
                return
            }
            
            let lines = observations.compactMap { $0.topCandidates(1).first?.string }
            //print("✅ [OCR] 인식된 텍스트 라인 수: \(lines.count)")
            //lines.forEach { print("• \($0)") }
            self.receiptData = lines.joined(separator: "\n")
            print("✅ [OCR] receiptData 저장 완료:\n\(self.receiptData)")
            
            completion(lines)
        }
        
        request.recognitionLevel = .accurate
        request.recognitionLanguages = ["ko-KR", "en-US"]
        request.usesLanguageCorrection = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try reqeustHandler.perform([request])
            } catch {
                print("❌ [OCR] requestHandler.perform 실패:", error.localizedDescription)
                completion([])
            }
        }
    }
    
    // 주소 추출 함수
    func extractAddress(from text: String) -> String? {
        let lines = text.components(separatedBy: .newlines)
        
        for line in lines {
            for region in regions {
                if line.hasPrefix(region) {
                    return line.trimmingCharacters(in: .whitespaces)
                }
            }
        }
        
        return nil
    }
    
    // 날짜 추출 함수
    func extractDate(from text: String) -> Date? {
        let lines = text.components(separatedBy: .newlines)
        let pattern = #"-?\s*(\d{2})/(\d{2})/(\d{2})\s+(\d{2})\s*:\s*(\d{2})\s*:\s*(\d{2})"#
        
        let regex = try? NSRegularExpression(pattern: pattern)
        
        for line in lines {
            if let match = regex?.firstMatch(in: line, range: NSRange(line.startIndex..., in: line)) {
                let matchedString = (line as NSString).substring(with: match.range)
                
                let formatter = DateFormatter()
                formatter.dateFormat = "yy/MM/ddHH:mm:ss" // 붙이기 전에 공백 제거할 거라 이렇게 써도 됨
                formatter.locale = Locale(identifier: "ko_KR")
                formatter.timeZone = .current
                
                // 공백 및 '-' 제거 후 파싱
                let cleaned = matchedString
                    .replacingOccurrences(of: "-", with: "")
                    .replacingOccurrences(of: "\\s+", with: "", options: .regularExpression)
                
                if let date = formatter.date(from: cleaned) {
                    print("✅ 추출 성공: \(date)")
                    return date
                }
            }
        }
        
        print("❌ 추출 실패")
        return nil
    }
    
    // 사용자에게 보여줄 날짜 포맷
    func formatDateToKorean(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월 d일 HH:mm:ss"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }
    
    // 영수증에서 구매한 물품 내역 정리
    func extractItems(from text: String) -> [ReceiptRow] {
        let allLines = text.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        
        let blacklistKeywords = ["합계", "할인", "포인트", "판촉", "과세", "부가세", "합", "신용카드", "카드", "총", "잔액", "매출"]
        
        let filteredLines = allLines.filter { line in
            !blacklistKeywords.contains { keyword in
                line.contains(keyword)
            }
        }
        
        var result: [ReceiptRow] = []
        var index = 0
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        
        while index + 2 < filteredLines.count {
            let name = filteredLines[index]
            let countLine = filteredLines[index + 1]
            let priceLine = filteredLines[index + 2]
            
            if let count = Int(countLine),
               let price = numberFormatter.number(from: priceLine)?.doubleValue {
                result.append(ReceiptRow(product: name, count: count, price: price))
                index += 3
            } else {
                index += 1
            }
        }
        
        return result
    }
    
    
    
}


// MARK: - Extension: 키보드 이벤트
extension ReceiptViewController {
    private func registerKeyboardNotification() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(_:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(_:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    //    @objc private func keyboardWillShow(_ notification: Notification) {
    //        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
    //
    //        let bottomInset = keyboardFrame.height - view.safeAreaInsets.bottom
    //        tableView.contentInset.bottom = bottomInset
    //        tableView.scrollIndicatorInsets.bottom = bottomInset
    //    }
    //
    //    @objc private func keyboardWillHide(_ notification: Notification) {
    //        tableView.contentInset.bottom = 0
    //        tableView.scrollIndicatorInsets.bottom = 0
    //    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            currentKeyboardHeight = keyboardFrame.height
            tableView.contentInset.bottom = keyboardFrame.height
            tableView.scrollIndicatorInsets.bottom = keyboardFrame.height
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        currentKeyboardHeight = nil
        tableView.contentInset.bottom = 0
        tableView.scrollIndicatorInsets.bottom = 0
    }
}


// MARK: - Extenson: 키보드 숨기기
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
}

