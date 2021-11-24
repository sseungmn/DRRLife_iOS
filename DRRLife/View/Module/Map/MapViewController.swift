//
//  MapViewController.swift
//  DRRLife
//
//  Created by OHSEUNGMIN on 2021/11/21.
//

import UIKit
import NMapsMap
import Then
import SnapKit
import CoreLocation

class MapViewController: UIViewController {
    var isRouteInputViewHidden: Bool = true
    lazy var locationManager = CLLocationManager()
    lazy var mapView = NMFMapView()
    lazy var scopeButton = UIButton().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 3
        $0.setImage(UIImage(systemName: "scope"), for: .normal)
        $0.addTarget(self, action: #selector(scopeButtonClicked), for: .touchUpInside)
    }
    
    @objc
    func scopeButtonClicked(_ sender: UIButton) {
        print("모드를 변경했습니다. (.compass)")
        mapView.positionMode = .compass
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setDelegate()
        setMap()
        setConstraints()
        
        if checkService() { mapView.positionMode = .compass }
        else { print("경고 문구 얼럿해야함")}
    }
    
    func setMap() {
        mapView.setLayerGroup(NMF_LAYER_GROUP_BICYCLE, isEnabled: true)
        mapView.setLayerGroup(NMF_LAYER_GROUP_TRANSIT, isEnabled: true)
        
        if !isRouteInputViewHidden {
            mapView.moveCamera(NMFCameraUpdate(scrollBy: CGPoint(x: 0, y: 100)))
        }
        
        if traitCollection.userInterfaceStyle == .dark {
            mapView.mapType = .navi
            mapView.isNightModeEnabled = true
        } else {
            mapView.mapType = .basic
            mapView.isNightModeEnabled = false
        }
    }
    
    func updateMap(to coor: Coordinate) {
        setCamera(to: coor)
        setMarker(to: coor)
    }
    
    func setCamera(to coor: Coordinate) {
        let camPosition = NMGLatLng(lat: coor.lat, lng: coor.lng)
        mapView.moveCamera(NMFCameraUpdate(scrollTo: camPosition))
        if !isRouteInputViewHidden {
            mapView.moveCamera(NMFCameraUpdate(scrollBy: CGPoint(x: 0, y: 100)))
        }
    }
    
    func setMarker(to coor: Coordinate) {
        Marker.shared.locationMarker.position = NMGLatLng(lat: coor.lat, lng: coor.lng)
        Marker.shared.locationMarker.mapView = mapView
        
        // 정보창 생성
//        let infoWindow = NMFInfoWindow()
//        let dataSource = NMFInfoWindowDefaultTextSource.data()
//        dataSource.title = "서울특별시청"
//        infoWindow.dataSource = dataSource
        
        // 마커에 달아주기
//        infoWindow.open(with: marker)
    }
    
    func setConstraints() {
        view.addSubview(mapView)
        view.addSubview(scopeButton)
        
        mapView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        scopeButton.snp.makeConstraints { make in
            make.size.equalTo(40)
            make.bottom.equalTo(view.safeArea.bottom).inset(40)
            make.leading.equalToSuperview().inset(15)
        }
    }
    
}

extension MapViewController: CLLocationManagerDelegate {
    
    func setDelegate() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
    }
    
    func checkService() -> Bool {
        if CLLocationManager.locationServicesEnabled() {
            print("위치 서비스 ON")
            locationManager.startUpdatingLocation()
            return true
        } else {
            print("위치 서비스 OFF")
            return false
        }
    }
}
