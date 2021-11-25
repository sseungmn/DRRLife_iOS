//
//  ViewController.swift
//  DRRLife
//
//  Created by OHSEUNGMIN on 2021/11/20.
//

import UIKit
import Then
import SnapKit
import Alamofire

class ViewController: UIViewController, LocationInfoDelegate {
    
    lazy var routeInputVC = RouteInputViewController()
    lazy var mapVC = MapViewController()
    lazy var locationInfoVC = LocationInfoViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setInnerView()
        setConstraints()
        
        routeInputVC.view.isHidden = true
        mapVC.isRouteInputViewHidden = true
    }
    
    func setInnerView() {
        self.add(mapVC)
        mapVC.delegate = self
        
        self.add(locationInfoVC)
        locationInfoVC.view.layer.masksToBounds = true
        locationInfoVC.view.layer.cornerRadius = 5
        
        self.add(routeInputVC)
        routeInputVC.mapView = mapVC
        
    }
    
    func setConstraints() {
        routeInputVC.view.snp.makeConstraints { make in
            make.top.equalTo(view.safeArea.top)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(200)
        }
        
        mapVC.view.snp.makeConstraints { make in
            make.top.left.right.bottom.equalToSuperview()
        }
        locationInfoVC.view.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(0)
        }
    }
    
    func showLocationInfo(with stationStatus: StationStatus) {
        print("프로토콜 실행중...")
        locationInfoVC.stationStatus = stationStatus
        locationInfoVC.updateData()
        if mapVC.isRouteInputViewHidden {
            mapVC.isRouteInputViewHidden = false
            showLocationInfoUI()
        }
    }
    
    func showLocationInfoUI() {
        mapVC.view.snp.updateConstraints { make in
            make.bottom.equalToSuperview().inset(250)
        }
        locationInfoVC.view.snp.updateConstraints { make in
            make.height.equalTo(260)
        }
    }
    
    func hideLocationInfo() {
        if !mapVC.isRouteInputViewHidden {
            hideLocationInfoUI()
            mapVC.isRouteInputViewHidden = true
        }
    }
    
    func hideLocationInfoUI() {
        mapVC.view.snp.updateConstraints { make in
            make.bottom.equalToSuperview()
        }
        locationInfoVC.view.snp.updateConstraints { make in
            make.height.equalTo(0)
        }
    }
}

