//
//  ReceiptViewController.swift
//  ReceiptMind
//
//  Created by 권정근 on 6/30/25.
//

import UIKit
import Vision
import Combine

class ReceiptViewController: UIViewController {
    
    
    // MARK: - Variable
    private let receiptImage: UIImage
    private let sectionTitle: [String] = ["영수증 사진", "지출 장소", "지출 날짜", "영수증 내역", "최종 금액", "메모"]
    private var receiptData: String = ""
    private var receiptViewModel: ReceiptViewModel = ReceiptViewModel()
    private var cancellables: Set<AnyCancellable> = []
    

    // 키보드 위치
    private var currentKeyboardHeight: CGFloat?
    
    // MARK: - UI Component
    private let tableView: UITableView = UITableView(frame: .zero, style: .insetGrouped)
    private var saveButton: UIButton = UIButton(type: .custom)
    
    
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
        
        let dashLines = detectDashLinePositions(from: receiptImage)
        let croppedImages = splitImage(receiptImage, at: dashLines)
        print("📸 자른 이미지 개수: \(croppedImages.count)")

        
//        splitImageByDashLine(receiptImage) { croppedImages in
//            print(croppedImages)
//            let previewVC = ImagePreviewViewController(images: croppedImages)
//            let nav = UINavigationController(rootViewController: previewVC)
//            self.present(nav, animated: true)
//        }

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
        
        saveButton.setTitle("저장하기", for: .normal)
        saveButton.layer.cornerRadius = 8
        saveButton.layer.borderWidth = 1
        saveButton.layer.borderColor = UIColor.label.cgColor
        saveButton.titleLabel?.font = .boldSystemFont(ofSize: 14)
        saveButton.setTitleColor(.label, for: .normal)
        saveButton.backgroundColor = .systemBlue
        saveButton.addTarget(self, action: #selector(saveReceipt), for: .touchUpInside)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(ReceiptImageCell.self, forCellReuseIdentifier: ReceiptImageCell.reuseIdentifier)
        tableView.register(ReceiptCommonCell.self, forCellReuseIdentifier: ReceiptCommonCell.reuseIdentifier)
        tableView.register(ReceiptMemoCell.self, forCellReuseIdentifier: ReceiptMemoCell.reuseIdentifier)
        tableView.register(ReceiptBreakdownCell.self, forCellReuseIdentifier: ReceiptBreakdownCell.reuseIdentifier)
        
        view.addSubview(tableView)
        view.addSubview(saveButton)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            tableView.bottomAnchor.constraint(equalTo: saveButton.topAnchor, constant: -12),
            
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12),
            saveButton.heightAnchor.constraint(equalToConstant: 44)
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
    
    func addDebugOverlay(to image: UIImage, index: Int) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: image.size)
        return renderer.image { context in
            image.draw(at: .zero)

            // 빨간색 테두리
            UIColor.red.setStroke()

            // 번호 표시
            let number = "\(index + 1)"
            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 40),
                .foregroundColor: UIColor.blue
            ]
            number.draw(at: CGPoint(x: 20, y: 20), withAttributes: attrs)
        }
    }

    
    @objc private func saveReceipt() {
        print("👍 saveReceipt 버튼 눌림")
        receiptViewModel.createReceipt(receiptViewModel.receiptItem, receiptImage)
        dismiss(animated: true)
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
//            guard let receiptID = receiptViewModel.receiptItem.id else {
//                print("❌ Receipt ID가 없습니다.")
//                return cell
//            }
            
            let receiptID = receiptViewModel.receiptItem.id
            
            let items = extractItems(from: receiptData, parentID: receiptID)
            receiptViewModel.receiptItem.list = items
            cell.configure(with: items, parentID: receiptID)
            cell.delegate = self
            return cell
            
        case 4:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ReceiptCommonCell.reuseIdentifier, for: indexPath) as? ReceiptCommonCell else { return ReceiptCommonCell() }
            cell.configure(with: "", delegate: self, tag: indexPath.section)
            cell.selectionStyle = .none
            return cell
            
        case 5:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ReceiptMemoCell.reuseIdentifier, for: indexPath) as? ReceiptMemoCell else { return ReceiptMemoCell() }
            cell.configure(with: "", delegate: self)
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
}


// MARK: - Extension: OCR 셋팅
extension ReceiptViewController {
    
    func detectDashLinePositions(from image: UIImage) -> [CGFloat] {
        guard let cgImage = image.cgImage else { return [] }
        let width = cgImage.width
        let height = cgImage.height

        guard let data = cgImage.dataProvider?.data,
              let bytes = CFDataGetBytePtr(data) else {
            return []
        }

        var dashLineYs: [CGFloat] = []

        let bytesPerPixel = 4
        let bytesPerRow = cgImage.bytesPerRow

        for y in 0..<height {
            var darkPixelCount = 0

            for x in 0..<width {
                let offset = y * bytesPerRow + x * bytesPerPixel
                let r = bytes[offset]
                let g = bytes[offset + 1]
                let b = bytes[offset + 2]

                let brightness = 0.299 * Double(r) + 0.587 * Double(g) + 0.114 * Double(b)
                if brightness < 50 {
                    darkPixelCount += 1
                }
            }

            let ratio = Double(darkPixelCount) / Double(width)
            if ratio > 0.5 { // 우선 50% 이상이면 로그 찍자
                print("🟡 구분선 후보 - y: \(y), 어두운 비율: \(Int(ratio * 100))%")
            }

            if ratio > 0.85 {
                dashLineYs.append(CGFloat(y))
                print("✅ 구분선 확정 - y: \(y), 어두운 비율: \(Int(ratio * 100))%")
            }
        }


        // 비슷한 y값(±5)을 묶어서 한 줄로 판단
        let grouped = dashLineYs.reduce(into: [CGFloat]()) { result, y in
            if let last = result.last, abs(last - y) < 5 {
                return
            }
            result.append(y)
        }

        return grouped
    }

    
    func splitImage(_ image: UIImage, at yPositions: [CGFloat]) -> [UIImage] {
        guard let cgImage = image.cgImage else { return [] }
        var croppedImages: [UIImage] = []

        var lastY: CGFloat = 0
        for y in yPositions {
            let height = y - lastY
            if height < 10 { continue } // 너무 얇으면 무시
            let rect = CGRect(x: 0, y: lastY, width: CGFloat(cgImage.width), height: height)
            if let cropped = cgImage.cropping(to: rect) {
                croppedImages.append(UIImage(cgImage: cropped))
            }
            lastY = y
        }

        // 마지막 잘린 부분도 추가
        let remainingHeight = CGFloat(cgImage.height) - lastY
        if remainingHeight > 10,
           let lastCrop = cgImage.cropping(to: CGRect(x: 0, y: lastY, width: CGFloat(cgImage.width), height: remainingHeight)) {
            croppedImages.append(UIImage(cgImage: lastCrop))
        }

        return croppedImages
    }

    
//    func splitImageByDashLine(_ image: UIImage, completion: @escaping ([UIImage]) -> Void) {
//        DispatchQueue.global(qos: .userInitiated).async {
//            guard let cgImage = image.cgImage else {
//                DispatchQueue.main.async {
//                    completion([])
//                }
//                return
//            }
//
//            let width = cgImage.width
//            let height = cgImage.height
//            let bytesPerPixel = 4
//            let bytesPerRow = bytesPerPixel * width
//            let bitsPerComponent = 8
//
//            guard let context = CGContext(data: nil,
//                                          width: width,
//                                          height: height,
//                                          bitsPerComponent: bitsPerComponent,
//                                          bytesPerRow: bytesPerRow,
//                                          space: CGColorSpaceCreateDeviceRGB(),
//                                          bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue),
//                  let pixelBuffer = context.data else {
//                DispatchQueue.main.async {
//                    completion([])
//                }
//                return
//            }
//
//            context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
//
//            let threshold = Int(Double(width) * 0.85)
//            var sectionBoundaries: [Int] = [0]
//
//            for y in 0..<height {
//                var darkPixelCount = 0
//
//                for x in 0..<width {
//                    let offset = y * bytesPerRow + x * bytesPerPixel
//                    let r = pixelBuffer.load(fromByteOffset: offset, as: UInt8.self)
//                    let g = pixelBuffer.load(fromByteOffset: offset + 1, as: UInt8.self)
//                    let b = pixelBuffer.load(fromByteOffset: offset + 2, as: UInt8.self)
//
//                    if r < 60 && g < 60 && b < 60 {
//                        darkPixelCount += 1
//                    }
//                }
//
//                if darkPixelCount >= threshold {
//                    sectionBoundaries.append(y)
//                }
//            }
//
//            sectionBoundaries.append(height)
//
//            var croppedImages: [UIImage] = []
//
//            for i in 0..<(sectionBoundaries.count - 1) {
//                let startY = sectionBoundaries[i]
//                let endY = sectionBoundaries[i + 1]
//                let cropRect = CGRect(x: 0, y: startY, width: width, height: endY - startY)
//
//                if let croppedCGImage = cgImage.cropping(to: cropRect) {
//                    let croppedImage = UIImage(cgImage: croppedCGImage)
//                    croppedImages.append(croppedImage)
//                }
//            }
//
//            DispatchQueue.main.async {
//                completion(croppedImages)
//            }
//        }
//    }

    
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
    
    // CoreData에 저장할 날짜 포맷
    func formatKoeranToDate(_ dateString: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월 d일 HH:mm:ss"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.date(from: dateString) ?? Date()
    }
    
    // 영수증에서 구매한 물품 내역 정리
    func extractItems(from text: String, parentID: UUID) -> [ReceiptRow] {
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
                let row = ReceiptRow(parentID: parentID, product: name, count: count, price: price)
                result.append(row)
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


// MARK: - Extension: ReceiptInputDelegate
extension ReceiptViewController: ReceiptInputDelegate {
    func didUpdateText(_ text: String, forSection section: Int) {
        switch section {
        case 1:
            receiptViewModel.receiptItem.place = text
        case 2:
            let date = self.formatKoeranToDate(text)
            receiptViewModel.receiptItem.date = date
        case 3:
            receiptViewModel.receiptItem.total = Double(text) ?? 0
        default:
            break
        }
    }
}


// MARK: - Extension: ReceiptMemoCellDelegate
extension ReceiptViewController: ReceiptMemoCellDelegate {
    func didUpdateMemo(_ memo: String) {
        //receipt.memo = memo
        receiptViewModel.receiptItem.memo = memo
    }
}


// MARK: - Extension: ReceiptBreakdownCellDelegate
extension ReceiptViewController: ReceiptBreakdownCellDelegate {
    func didAddNewRow() {
        let receiptID = receiptViewModel.receiptItem.id
        
        receiptViewModel.receiptItem.list.append(ReceiptRow(parentID: receiptID , product: "", count: 0, price: 0.0))
    }
    
    func didDeleteRow(at index: Int) {
        if receiptViewModel.receiptItem.list.indices.contains(index) {
            receiptViewModel.receiptItem.list.remove(at: index)
        }
    }
    
    func didUpdateRow(_ row: ReceiptRow, at index: Int) {
        print("▶️ \(index)번째 row 업데이트: \(row)")
        //receipt.list[index] = row
        receiptViewModel.receiptItem.list[index] = row
    }
}
