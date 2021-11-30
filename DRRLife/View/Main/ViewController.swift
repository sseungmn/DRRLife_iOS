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

class ViewController: UIViewController, ContainerDelegate, RouteInfoDelegate {
    
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
    lazy var routeInfoVC = RouteInfoViewController()
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
        showRouteInput()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        
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
        routeInputVC.routeInfoVC = routeInfoVC
        routeInputVC.delegate = self
        
        self.add(routeInfoVC)
        routeInfoVC.view.layer.masksToBounds = true
        routeInfoVC.view.layer.cornerRadius = 5
    }
    
    func setConstraints() {
        routeButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeArea).inset(20)
            make.left.right.equalToSuperview().inset(20)
        }
        routeInputVC.view.snp.makeConstraints { make in
            make.top.equalTo(view.safeArea)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(200)
        }
        
        mapVC.view.snp.makeConstraints { make in
            make.top.left.right.bottom.equalToSuperview()
        }
        locationInfoVC.view.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(view.safeArea)
            make.height.equalTo(0)
        }
        routeInfoVC.view.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(view.safeArea)
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
    
    // MARK: Manipulate locationInfo
    
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
        UIView.animate(withDuration: 0.5, delay: 0.5) {
            self.locationInfoVC.view.snp.updateConstraints { make in
                make.height.equalTo(160)
            }
            self.mapVC.view.snp.remakeConstraints { make in
                make.top.left.right.equalToSuperview()
                make.bottom.equalTo(self.view.safeArea).inset(155)
            }
        }
    }
    
    func hideLocationInfo() {
        if !isLocationInfoViewHidden {
            hideLocationInfoUI()
            isLocationInfoViewHidden = true
        }
    }
    
    func hideLocationInfoUI() {
        mapVC.view.snp.remakeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(view)
        }
        locationInfoVC.view.snp.updateConstraints { make in
            make.bottom.equalTo(view.safeArea)
            make.height.equalTo(0)
        }
    }
    
    // MARK: Manipulate RouteInput
    
    func showRouteInput() {
        routeInputVC.view.isHidden = false
        isRouteInputViewHidden = false
    }
    
    func hideRouteInput() {
        routeInputVC.view.isHidden = true
        isRouteInputViewHidden = true
    }
    
    // MARK: Manipulate RouteInfo
    
    func showRouteInfo() {
        hideLocationInfo()
        showRouteInfoUI()
    }
    
    func showRouteInfoUI() {
        UIView.animate(withDuration: 0.5, delay: 0.5) {
            self.routeInfoVC.view.snp.updateConstraints { make in
                make.height.equalTo(254)
            }
            self.mapVC.view.snp.remakeConstraints { make in
                make.top.left.right.equalToSuperview()
                make.bottom.equalTo(self.view.safeArea).inset(249)
            }
        }
    }
    
    func hideRouteInfo() {
        mapVC.view.snp.remakeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(view)
        }
        routeInfoVC.view.snp.updateConstraints { make in
            make.bottom.equalTo(view.safeArea)
            make.height.equalTo(0)
        }
    }
}

