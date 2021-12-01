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
    func addShadow() {
        self.view.layer.shadowRadius = 5
        self.view.layer.shadowColor = UIColor.black.cgColor
        self.view.layer.shadowOpacity = 0.3
        // shadow곡선을 렌더링 하는데 시간이 너무 많이 들기 때문에, 베지에 곡선을 써주어야 한다.
        self.view.layer.shadowPath = UIBezierPath(rect: self.view.bounds).cgPath
        self.view.layer.shouldRasterize = true
    }
}
