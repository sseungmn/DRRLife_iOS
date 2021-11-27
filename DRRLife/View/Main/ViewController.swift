//
//  ViewController.swift
//  DRRLife
//
//  Created by OHSEUNGMIN on 2021/11/20.
//

import UIKit
import Alamofire
import Then
import SnapKit

class ViewController: UIViewController, LocationInfoDelegate {
    
    var isRouteInputViewHidden: Bool {
        get {
            return mapVC.isRouteInputViewHidden
        }
        set(value) {
            mapVC.isRouteInputViewHidden = value
        }
    }
    var isLocationInfoViewHidden = true
    
    lazy var routeInputVC = RouteInputViewController()
    lazy var mapVC = MapViewController()
    lazy var locationInfoVC = LocationInfoViewController()
    lazy var routeButton = UIButton().then {
        $0.setTitle("길찾기", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = .boldThemeFont(ofSize: 20)
        
        $0.backgroundColor = .themeMain
        $0.layer.cornerRadius = 15
        
        $0.addTarget(self, action: #selector(routeButtonClicked), for: .touchUpInside)
    }
    @objc
    func routeButtonClicked() {
        routeInputVC.view.isHidden = false
        isRouteInputViewHidden = false
    }
    
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
        
        view.addSubview(routeButton)
        
        self.add(locationInfoVC)
        locationInfoVC.view.layer.masksToBounds = true
        locationInfoVC.view.layer.cornerRadius = 5
        
        locationInfoVC.delegate = routeInputVC
        locationInfoVC.mapVC = mapVC
        
        self.add(routeInputVC)
        routeInputVC.mapVC = mapVC
    }
    
    func setConstraints() {
        routeButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeArea.top).inset(20)
            make.left.right.equalToSuperview().inset(20)
        }
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
    
    func getStationStatus(stationStatus: StationStatus, tag: Int) {
        if tag == 1 {
            routeInputVC.setTitle(of: routeInputVC.oriRantalStationInput, with: stationStatus.stationName)
            routeInputVC.routeParams.originStation = stationStatus
        } else {
            routeInputVC.setTitle(of: routeInputVC.dstRantalStationInput, with: stationStatus.stationName)
            routeInputVC.routeParams.destinationStation = stationStatus
        }
    }
    
    func showLocationInfo(with stationStatus: StationStatus) {
        print("프로토콜 실행중...")
        locationInfoVC.stationStatus = stationStatus
        locationInfoVC.updateData()
        if isLocationInfoViewHidden {
            isLocationInfoViewHidden = false
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
        if !isLocationInfoViewHidden {
            hideLocationInfoUI()
            isLocationInfoViewHidden = true
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

