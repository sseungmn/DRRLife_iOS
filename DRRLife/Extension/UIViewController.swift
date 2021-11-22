//
//  UIViewController.swift
//  DRRLife
//
//  Created by OHSEUNGMIN on 2021/11/22.
//

import Foundation
import UIKit

extension UIViewController {
    func add(_ child: UIViewController) {
        addChild(child)
        view.addSubview(child.view)
        child.didMove(toParent: self)
    }
    
    func remove() {
        guard parent != nil else { return }
        
        view.removeFromSuperview()
        removeFromParent()
    }
}
