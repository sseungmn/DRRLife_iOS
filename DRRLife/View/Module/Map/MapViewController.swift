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

protocol LocationInfoDelegate {
    func showLocationInfo(with stationStatus: StationStatus)
}

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
    lazy var stationToggleButton = UIButton().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 3
        $0.setImage(UIImage(systemName: "bicycle.circle"), for: .normal)
        $0.setImage(UIImage(systemName: "bicycle.circle.fill"), for: .selected)
        $0.isSelected = true
        $0.setPointSize(pointSize: 22)
        $0.addTarget(self, action: #selector(stationButtonToggled), for: .touchUpInside)
    }
    lazy var updateButton = UIButton().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 3
        $0.setImage(UIImage(systemName: "arrow.triangle.2.circlepath"), for: .normal)
        $0.addTarget(self, action: #selector(updateButtonClicked), for: .touchUpInside)
    }
    var stations = [StationStatus]()
    
    @objc
    func scopeButtonClicked(_ sender: UIButton) {
        print("모드를 변경했습니다. (.compass)")
        mapView.positionMode = .compass
        mapView.moveCamera(NMFCameraUpdate(scrollBy: CGPoint(x: 0, y: 100))) // 검색창이 차지하는 부분만큼 중앙좌표를 내려준다.
    }
    
    @objc
    func stationButtonToggled(_ sender: UIButton) {
        if !sender.isSelected {
            sender.isSelected.toggle()
            Marker.shared.showStationMarkers(mapView: mapView)
        } else {
            sender.isSelected.toggle()
            Marker.shared.hideStationMarkers()
        }
    }
    @objc
    func updateButtonClicked(_ sender: UIButton) {
        print("Update Button Clicked")
    }
    
    var delegate: LocationInfoDelegate?
    func showLocationInfo(stationStatus: StationStatus) {
        delegate?.showLocationInfo(with: stationStatus)
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
        
        if traitCollection.userInterfaceStyle == .dark {
            mapView.mapType = .navi
            mapView.isNightModeEnabled = true
        } else {
            mapView.mapType = .basic
            mapView.isNightModeEnabled = false
        }
        self.setStaionListAndSetStationMarkers(count: 3000)
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
        view.addSubview(stationToggleButton)
        view.addSubview(updateButton)
        
        mapView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        updateButton.snp.makeConstraints { make in
            make.size.equalTo(40)
            make.bottom.equalTo(view.safeArea.bottom).inset(140)
            make.leading.equalToSuperview().inset(15)
        }
        
        stationToggleButton.snp.makeConstraints { make in
            make.size.equalTo(40)
            make.bottom.equalTo(view.safeArea.bottom).inset(90)
            make.leading.equalToSuperview().inset(15)
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

// MARK: 공공자전거 실시간 대여정보 API
extension MapViewController {
    /// API를 사용해서 실시간 대여정보를 받아오고, 대여소 Marker을 생성한다.
    func setStaionListAndSetStationMarkers(count: Int) {
        self.stations.removeAll()
        Marker.shared.stationMarkers.removeAll()
        
        var start = 1
        var end = count > 1000 ? 1000 : count
        
        while start <= end {
            requestRantalStationList(start, end)
            start += 1000
            end = end + 1000 <= count ? end + 1000 : count
        }
    }
    
    func requestRantalStationList(_ start: Int, _ end: Int) {
        RequestURL.parameters["START_INDEX"] = start
        RequestURL.parameters["END_INDEX"] = end
        print("\(start)~\(end)")
        
        AF.request(RequestURL.requestURL,
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
        })
    }
    
    func makeStationMarker(station: StationStatus) {
        print("\(station.stationName) 마커 추가하는중")
        
        let tmpMarker = NMFMarker(position: NMGLatLng(lat: station.coordinate.lat,
                                                      lng: station.coordinate.lng))
        let userInfo: [AnyHashable : Any] = ["mapVC" : self,
                                             "stationStatus" : station]
        tmpMarker.userInfo = userInfo
        tmpMarker.mapView = mapView
        tmpMarker.touchHandler = { (overlay: NMFOverlay) -> Bool in
            guard let mapVC = userInfo["mapVC"] as? MapViewController else {
                print("해당 MapView가 존재하지 않습니다.")
                return true
            }
            guard let stationStatus = userInfo["stationStatus"] as? StationStatus else {
                print("해당 stationStatus가 존재하지 않습니다.")
                return true
            }
            print("\(stationStatus.stationName)에서 touchEvent 발생")
            mapVC.setCamera(to: stationStatus.coordinate)
            mapVC.showLocationInfo(stationStatus: stationStatus)
            return true
        }
        
        tmpMarker.width = 20
        tmpMarker.height = 30
        tmpMarker.iconImage = NMF_MARKER_IMAGE_BLACK
        tmpMarker.iconTintColor = calcMarkerColor(by: station.parkingBikeTotCnt)
        tmpMarker.captionText = station.stationName
        
        tmpMarker.isHideCollidedSymbols = true
        tmpMarker.isHideCollidedCaptions = true
        tmpMarker.minZoom = calcMinZoomLevel(by: station.rackTotCnt)
        
        
        Marker.shared.stationMarkers.append(tmpMarker)
    }
    
    func calcMarkerColor(by parkingBikeTotCnt: Int) -> UIColor {
        if parkingBikeTotCnt == 0 {
            return .gray
        } else if parkingBikeTotCnt <= 5 {
            return .red
        } else if parkingBikeTotCnt <= 10 {
            return .orange
        } else {
            return .green
        }
    }
    
    func calcMinZoomLevel(by rackTotCnt: Int) -> Double {
        if rackTotCnt < 10 {
            return NMF_MIN_ZOOM + 14
        } else if rackTotCnt < 15 {
            return NMF_MIN_ZOOM + 12
        } else if rackTotCnt < 20 {
            return NMF_MIN_ZOOM + 10
        } else if rackTotCnt < 30 {
            return NMF_MIN_ZOOM + 8
        } else {
            return NMF_MIN_ZOOM + 6
        }
    }
}
