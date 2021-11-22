//
//  ViewController.swift
//  DRRLife
//
//  Created by OHSEUNGMIN on 2021/11/20.
//

import UIKit
import Then
import SnapKit

class ViewController: UIViewController {
    lazy var routeInputVC = RouteInputViewController()
    lazy var mapVC = MapViewController()
    lazy var locationInfoVC = LocationInfoViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setInnerView()
        setConstraints()
        routeInputVC.view.snp.updateConstraints { make in
            make.height.equalTo(181)
        }
        locationInfoVC.view.snp.updateConstraints { make in
            make.height.equalTo(200)
        }
    }
    
    func setInnerView() {
        self.add(routeInputVC)
        self.add(mapVC)
        self.add(locationInfoVC)
    }
    
    func setConstraints() {
        routeInputVC.view.snp.makeConstraints { make in
            make.top.equalTo(view.safeArea.top)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(mapVC.view.snp.top)
            make.height.equalTo(0)
        }
        
        mapVC.view.snp.makeConstraints { make in
            make.top.equalTo(routeInputVC.view.snp.bottom)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(locationInfoVC.view.snp.top)
        }
        
        locationInfoVC.view.snp.makeConstraints { make in
            make.top.equalTo(mapVC.view.snp.bottom)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(view.safeArea.bottom)
            make.height.equalTo(0)
        }
    }
}
