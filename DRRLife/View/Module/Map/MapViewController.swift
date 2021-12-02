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
import Alamofire

protocol ContainerDelegate {
    func showLocationInfo(with stationStatus: StationStatus)
    func hideLocationInfo()
    func hideRouteInput()
    func hideRouteInfo()
}

class MapViewController: UIViewController {
    var isRouteInputViewHidden: Bool = true
    var countUpdatingStationQuene: Int = 0
    var stations = [StationStatus]()
    lazy var locationManager = CLLocationManager()
    lazy var mapView = NMFMapView()
    
    var containerDelegate: ContainerDelegate?
    var progressDelegate: ProgressHUDDelegate?
    
    // MARK: ScopeButton
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
        if !isRouteInputViewHidden {
            mapView.moveCamera(NMFCameraUpdate(scrollBy: CGPoint(x: 0, y: 100))) // 검색창이 차지하는 부분만큼 중앙좌표를 내려준다.
        }
    }
    
    // MARK: StationToggleButton
    lazy var stationToggleButton = UIButton().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 3
        $0.setImage(UIImage(named: "bicycle.circle"), for: .normal)
        $0.setImage(UIImage(named: "bicycle.circle.fill"), for: .selected)
        $0.isSelected = true
        $0.setPointSize(pointSize: 22)
        $0.addTarget(self, action: #selector(stationButtonToggled), for: .touchUpInside)
    }
    @objc
    func stationButtonToggled(_ sender: UIButton) {
        if !sender.isSelected {
            sender.isSelected.toggle()
            MarkerManager.shared.showStationMarkers(mapView: mapView)
        } else {
            sender.isSelected.toggle()
            MarkerManager.shared.hideStationMarkers()
        }
    }
    
    // MARK: UpdateButton
    lazy var updateButton = UIButton().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 3
        $0.setImage(UIImage(named: "arrow.triangle.2.circlepath"), for: .normal)
        $0.addTarget(self, action: #selector(updateButtonClicked), for: .touchUpInside)
    }
    @objc
    func updateButtonClicked(_ sender: UIButton) {
        print("Update Button Clicked")
        self.setStaionListAndSetStationMarkers(count: 3000)
    }
    
    func showLocationInfo(stationStatus: StationStatus) {
        containerDelegate?.showLocationInfo(with: stationStatus)
    }
}

// MARK: Init
extension MapViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setLocationManagerDelegate()
        self.setMapDelegate()
        self.setMap()
        self.setConstraints()
        
        if self.checkService() { mapView.positionMode = .compass }
        else { print("경고 문구 얼럿해야함")}
    }
    
    func setConstraints() {
        view.addSubview(mapView)
        view.addSubview(scopeButton)
        view.addSubview(stationToggleButton)
        view.addSubview(updateButton)
        
        mapView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        updateButton.snp.makeConstraints { make in
            make.size.equalTo(40)
            make.bottom.equalTo(view.safeArea).inset(140)
            make.leading.equalToSuperview().inset(15)
        }
        
        stationToggleButton.snp.makeConstraints { make in
            make.size.equalTo(40)
            make.bottom.equalTo(view.safeArea).inset(90)
            make.leading.equalToSuperview().inset(15)
        }
        
        scopeButton.snp.makeConstraints { make in
            make.size.equalTo(40)
            make.bottom.equalTo(view.safeArea).inset(40)
            make.leading.equalToSuperview().inset(15)
        }
    }
    
    func setMap() {
        mapView.setLayerGroup(NMF_LAYER_GROUP_BICYCLE, isEnabled: true)
        mapView.setLayerGroup(NMF_LAYER_GROUP_TRANSIT, isEnabled: true)
        
        // 다크모드 대응
//        if traitCollection.userInterfaceStyle == .dark {
//            mapView.mapType = .navi
//            mapView.isNightModeEnabled = true
//        } else {
//            mapView.mapType = .basic
//            mapView.isNightModeEnabled = false
//        }
        self.setStaionListAndSetStationMarkers(count: 3000)
    }
}

// MARK: Manipulate Map
extension MapViewController: NMFMapViewTouchDelegate {
    
    func setMapDelegate() {
        mapView.touchDelegate = self
    }
    
    func mapView(_ mapView: NMFMapView, didTapMap latlng: NMGLatLng, point: CGPoint) {
        containerDelegate?.hideLocationInfo()
        containerDelegate?.hideRouteInput()
        containerDelegate?.hideRouteInfo()
        MarkerManager.shared.selectedMarker = nil
    }
    
    func updateMap(to coor: Coordinate) {
        setCamera(to: coor)
//        setMarker(to: coor)
    }
    
    func setCamera(to coor: Coordinate) {
        let camPosition = NMGLatLng(lat: coor.lat, lng: coor.lng)
        mapView.moveCamera(NMFCameraUpdate(scrollTo: camPosition))
        if !isRouteInputViewHidden {
            mapView.moveCamera(NMFCameraUpdate(scrollBy: CGPoint(x: 0, y: 100)))
        }
    }
    
    func setMarker(to coor: Coordinate) {
        MarkerManager.shared.locationMarker.position = NMGLatLng(lat: coor.lat, lng: coor.lng)
        MarkerManager.shared.locationMarker.mapView = mapView
    }
}
    

extension MapViewController: CLLocationManagerDelegate {
    
    func setLocationManagerDelegate() {
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

// MARK: 공공자전거 실시간 대여정보 API
extension MapViewController {
    /// API를 사용해서 실시간 대여정보를 받아오고, 대여소 Marker을 생성한다.
    func setStaionListAndSetStationMarkers(count: Int) {
        if countUpdatingStationQuene != 0 {
            print("이미 대여소 업데이트를 진행중입니다.")
            return
        }
        // 중복 처리 방지
        self.stations.removeAll()
        MarkerManager.shared.hideStationMarkers() // 기존의 마커들을 맵에서 제거한다.
        MarkerManager.shared.stationMarkers.removeAll()
        progressDelegate?.startProgress()
        var start = 1
        var end = count > 1000 ? 1000 : count
        
        while start <= end {
            requestRantalStationList(start, end)
            start += 1000
            end = end + 1000 <= count ? end + 1000 : count
        }
    }
    
    func requestRantalStationList(_ start: Int, _ end: Int) {
        self.countUpdatingStationQuene += 1
        SODRequestURL.parameters["START_INDEX"] = start
        SODRequestURL.parameters["END_INDEX"] = end
        print("\(start)~\(end)")
        
        AF.request(SODRequestURL.requestURL,
                   method: .get,
                   parameters: nil,
                   headers: nil
        ).responseJSON(completionHandler: { response in
            switch response.result {
            case .success(let jsonData):
                print("===== 검색 성공 =====")
                do {
                    let json = try JSONSerialization.data(withJSONObject: jsonData, options: .prettyPrinted)
                    let result = try JSONDecoder().decode(SODResponse.self, from: json)
                    print("===== 검색 결과 '\(result.rentBikeStatus.row.count)개'")
                    for stationInfo in result.rentBikeStatus.row {
                        let tmpStationDetail = stationInfo.makeStationDetail()
                        self.stations.append(tmpStationDetail)
                        self.makeStationMarker(station: tmpStationDetail)
                    }
                } catch(let error) {
                    print(error.localizedDescription)
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
            self.countUpdatingStationQuene -= 1
            if self.countUpdatingStationQuene == 0 {
                self.progressDelegate?.stopProgress()
            }
        })
    }
    func makeParamMarker(coor: Coordinate, for type: RouteInputType) {
        let tmpMarker = MarkerManager.shared.getParamMarker(type: type)
        tmpMarker.position = NMGLatLng(from: coor.toCLLocationCoordinate2D)
        tmpMarker.mapView = mapView
        tmpMarker.register()
    }
    
    func makeStationMarker(station: StationStatus) {
        let tmpMarker = StationMarker(station: station, mapVC: self)
        MarkerManager.shared.stationMarkers.append(tmpMarker)
    }
}
