//
//  ReceiptBreakdownCell.swift
//  ReceiptMind
//
//  Created by 권정근 on 7/1/25.
//

import UIKit

class ReceiptBreakdownCell: UITableViewCell {
    
    
    // MARK: - Variable
    static let reuseIdentifier: String = "ReceiptBreakdownCell"
    private var collectionViewHeightConstraint: NSLayoutConstraint?
    
    private var data: [ReceiptRow] = []
    
    
    // MARK: - UI Component
    private var collectionView: UICollectionView!
    
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .systemBackground
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Function
    private func setupUI() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width, height: 44)
        
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: self.createLayout())
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.register(ReceiptHeaderCell.self, forCellWithReuseIdentifier: ReceiptHeaderCell.reuseIdentifier)
        collectionView.register(ReceiptRowCell.self, forCellWithReuseIdentifier: ReceiptRowCell.reuseIdentifier)
        collectionView.dataSource = self
        
        collectionView.backgroundColor = .clear
        collectionView.isScrollEnabled = false
        
        
        
        contentView.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
        
        collectionViewHeightConstraint = collectionView.heightAnchor.constraint(equalToConstant: 88)
        collectionViewHeightConstraint?.isActive = true
    }
    
    func configure(with data: [ReceiptRow]) {
        self.data = data
        DispatchQueue.main.async {
            self.collectionView.reloadData()
            let contentHeight = self.collectionView.collectionViewLayout.collectionViewContentSize.height
            let newHeight = max(88, contentHeight)
            self.collectionViewHeightConstraint?.constant = newHeight
        }
    }
    
    
    func createLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { section, _ in
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                  heightDimension: .absolute(44))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                   heightDimension: .absolute(44))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                           subitem: item,
                                                           count: 1)
            let section = NSCollectionLayoutSection(group: group)
            return section
        }
    }
}


// MARK: - Extension
extension ReceiptBreakdownCell: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return section == 0 ? 1 : 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            return collectionView.dequeueReusableCell(withReuseIdentifier: ReceiptHeaderCell.reuseIdentifier, for: indexPath)
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReceiptRowCell.reuseIdentifier, for: indexPath) as! ReceiptRowCell
//            let row = data[indexPath.item]
//            cell.nameField.text = row.product
//            cell.quantityField.text = "\(row.count)"
//            cell.priceField.text = "\(row.price)"
            return cell
        }
    }
}
