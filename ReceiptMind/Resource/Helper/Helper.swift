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
