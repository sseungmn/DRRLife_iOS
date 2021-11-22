//
//  UITextField.swift
//  DRRLife
//
//  Created by OHSEUNGMIN on 2021/11/23.
//

import Foundation
import UIKit

extension UITextField {
  func addLeftPadding() {
    let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: self.frame.height))
    self.leftView = paddingView
    self.leftViewMode = ViewMode.always
  }
  func setPlaceholderColor(_ placeholderColor: UIColor) {
    attributedPlaceholder = NSAttributedString(
        string: placeholder  ??  "",
        attributes: [
            .foregroundColor: placeholderColor,
            .font: font
        ].compactMapValues { $0 }
    )
    }
}
