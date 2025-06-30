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
    private let sectionTitle: [String] = ["영수증 사진", "영수증 내역"]
    
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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        performOCR(on: receiptImage) { [weak self] lines in
        }
    }
    
    
    // MARK: - Function
    private func setupUI() {
        tableView.showsLargeContentViewer = false
        tableView.backgroundColor = .systemBackground
        tableView.layer.cornerRadius = 8
        tableView.rowHeight = 200
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(ReceiptImageCell.self, forCellReuseIdentifier: ReceiptImageCell.reuseIdentifier)
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12)
        ])
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
extension ReceiptViewController: UITableViewDelegate, UITableViewDataSource {
    
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
            return cell
        case 1:
            return UITableViewCell()
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 400
        case 1:
            return UITableView.automaticDimension
        default:
            return UITableView.automaticDimension
        }
    }
    
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
            print("✅ [OCR] 인식된 텍스트 라인 수: \(lines.count)")
            lines.forEach { print("• \($0)") }
            
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
    
    //    'func recognizeText(from image: UIImage) {
    //        guard let cgImage = image.cgImage else {
    //            print("CGImage 변환 실패")
    //            return
    //        }
    //
    //        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
    //
    //        let request = VNRecognizeTextRequest { request, error in
    //            if let error = error {
    //                print("OCR 실패:", error.localizedDescription)
    //                return
    //            }
    //
    //            guard let observations = request.results as? [VNRecognizedTextObservation] else {
    //                print("OCR 결과 없음")
    //                return
    //            }
    //
    //            let lines = observations.compactMap { $0.topCandidates(1).first?.string }
    //
    //            // ✅ 여기서 콘솔 출력
    //            print("========== OCR 결과 ==========")
    //            lines.forEach { print($0) }
    //            print("=============================")
    //        }
    //
    //        request.recognitionLevel = .accurate
    //        request.recognitionLanguages = ["ko-KR", "en-US"]
    //        request.usesLanguageCorrection = true
    //
    //        DispatchQueue.global(qos: .userInitiated).async {
    //            do {
    //                try requestHandler.perform([request])
    //            } catch {
    //                print("OCR 요청 실패:", error)
    //            }
    //        }
    //    }
}
