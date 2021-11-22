//
//  UIButton.swift
//  DRRLife
//
//  Created by OHSEUNGMIN on 2021/11/23.
//

import Foundation
import UIKit

extension UIButton {
    func setPointSize(pointSize: CGFloat) {
        let config = UIImage.SymbolConfiguration(pointSize: pointSize)
        self.setPreferredSymbolConfiguration(config, forImageIn: .normal)
    }
}
