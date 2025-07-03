//
//  ReceiptBreakdownCell.swift
//  ReceiptMind
//
//  Created by 권정근 on 7/1/25.
//

import UIKit

class ReceiptBreakdownCell: UITableViewCell {
    
    static let reuseIdentifier = "ReceiptBreakdownCell"
    private var collectionViewHeightConstraint: NSLayoutConstraint?
    private var data: [ReceiptRow] = [] {
        didSet {
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    private var collectionView: UICollectionView!
    private let addButton: UIButton = UIButton(type: .system)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .systemBackground
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width - 32, height: 44)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.isScrollEnabled = false
        collectionView.dataSource = self
        collectionView.register(ReceiptHeaderCell.self, forCellWithReuseIdentifier: ReceiptHeaderCell.reuseIdentifier)
        collectionView.register(ReceiptRowCell.self, forCellWithReuseIdentifier: ReceiptRowCell.reuseIdentifier)
        
        addButton.setTitle("+ 항목 추가", for: .normal)
        addButton.layer.cornerRadius = 16
        addButton.titleLabel?.font = .boldSystemFont(ofSize: 14)
        addButton.setTitleColor(.label, for: .normal)
        addButton.backgroundColor = .systemBlue
        addButton.addTarget(self, action: #selector(didTapAddRow), for: .touchUpInside)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(collectionView)
        contentView.addSubview(addButton)
        
        collectionViewHeightConstraint = collectionView.heightAnchor.constraint(equalToConstant: 0)
        collectionViewHeightConstraint?.isActive = true
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: addButton.topAnchor, constant: -12),
            
            addButton.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor, constant: -12),
            addButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            addButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            addButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    func configure(with data: [ReceiptRow]) {
        self.data = data
        collectionView.reloadData()
        
        // 셀 개수 + header 1개 * 50 높이
        let height = CGFloat(data.count + 1) * 50
        collectionViewHeightConstraint?.constant = height
    }
    
    @objc private func didTapAddRow() {
        data.append(ReceiptRow(product: "", count: 0, price: 0.0))
        collectionView.reloadData()
        updateCollectionViewHeight()
    }
    
    func updateCollectionViewHeight() {
        let height = CGFloat(data.count + 1) * 50
        collectionViewHeightConstraint?.constant = height
        
        // 🔥 중요: 레이아웃 갱신
        self.setNeedsLayout()
        self.layoutIfNeeded()
        
        // 셀 높이 갱신 유도
        if let tableView = self.superview(of: UITableView.self) {
            tableView.beginUpdates()
            tableView.endUpdates()
        }
    }
}



// MARK: - Extension: UICollectionViewDataSource
extension ReceiptBreakdownCell: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return section == 0 ? 1 : data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            return collectionView.dequeueReusableCell(withReuseIdentifier: ReceiptHeaderCell.reuseIdentifier, for: indexPath)
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReceiptRowCell.reuseIdentifier, for: indexPath) as! ReceiptRowCell
    
            
            let item = data[indexPath.item]
            cell.nameField.text = item.product
            cell.quantityField.text = "\(item.count)"
            cell.priceField.text = "\(item.price)"
            cell.delegate = self
            return cell
        }
    }
}


// MARK: - Extension: ReceiptRowCellDelegate
extension ReceiptBreakdownCell: ReceiptRowCellDelegate {
    func didTapDelete(in cell: ReceiptRowCell) {
        guard let indexPath = collectionView.indexPath(for: cell),
              indexPath.section == 1 else { return }
        
        data.remove(at: indexPath.item)
        collectionView.reloadData()
        updateCollectionViewHeight()
    }
}
