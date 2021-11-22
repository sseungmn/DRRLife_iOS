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
    lazy var routeInputContainer = UIView().then {
        $0.backgroundColor = .white
        $0.clipsToBounds = true
    }
    lazy var mapContainer = UIView().then {
        $0.backgroundColor = .white
        $0.clipsToBounds = true
    }
    
    lazy var locationInfoContainer = UIView().then {
        $0.backgroundColor = .white
        $0.clipsToBounds = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setConstraints()
        setInnerView()
        routeInputContainer.snp.updateConstraints { make in
            make.height.equalTo(0)
        }
        locationInfoContainer.snp.updateConstraints { make in
            make.height.equalTo(300)
        }
    }
    
    func setConstraints() {
        view.addSubview(routeInputContainer)
        view.addSubview(mapContainer)
        view.addSubview(locationInfoContainer)
        routeInputContainer.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(mapContainer.snp.top)
            make.height.equalTo(0)
        }
        mapContainer.snp.makeConstraints { make in
            make.top.equalTo(routeInputContainer.snp.bottom)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(locationInfoContainer.snp.top)
        }
        locationInfoContainer.snp.makeConstraints { make in
            make.top.equalTo(mapContainer.snp.bottom)
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(0)
        }
    }
    
    func setInnerView() {
        let routeInputVC = RouteInputViewController()
        routeInputContainer.addSubview(routeInputVC.view)
        routeInputVC.view.frame = routeInputContainer.frame
        
        let mapVC = MapViewController()
        mapContainer.addSubview(mapVC.view)
        mapVC.view.frame = mapContainer.frame
        
        let locationInfoVC = LocationInfoViewController()
        locationInfoContainer.addSubview(locationInfoVC.view)
        locationInfoVC.view.frame = locationInfoContainer.frame
    }
}
