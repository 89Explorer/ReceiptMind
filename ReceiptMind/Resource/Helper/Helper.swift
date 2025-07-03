//
//  Helper.swift
//  ReceiptMind
//
//  Created by 권정근 on 7/1/25.
//

import Foundation
import UIKit

extension UITextField {
  func addLeftPadding() {
    let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: self.frame.height))
    self.leftView = paddingView
    self.leftViewMode = ViewMode.always
  }
}


extension UIView {
    func superview<T: UIView>(of type: T.Type) -> T? {
        var current = self.superview
        while let view = current {
            if let view = view as? T {
                return view
            }
            current = view.superview
        }
        return nil
    }
}

let regions = [
    "서울", "서울특별시",
    "부산", "부산광역시",
    "대구", "대구광역시",
    "인천", "인천광역시",
    "광주", "광주광역시",
    "대전", "대전광역시",
    "울산", "울산광역시",
    "세종", "세종특별자치시",
    "경기", "경기도",
    "강원", "강원도",
    "충북", "충청북도",
    "충남", "충청남도",
    "전북", "전라북도",
    "전남", "전라남도",
    "경북", "경상북도",
    "경남", "경상남도",
    "제주", "제주특별자치도"
]
