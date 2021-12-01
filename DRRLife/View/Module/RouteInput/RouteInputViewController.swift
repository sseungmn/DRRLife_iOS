//
//  RouteInputViewController.swift
//  DRRLife
//
//  Created by OHSEUNGMIN on 2021/11/22.
//
import UIKit
import SnapKit
import Then
import Alamofire
import NMapsMap
import MBProgressHUD

protocol RouteInfoDelegate {
    func showRouteInfo()
    func hideRouteInfo()
    func hideRouteInfoButton()
}

protocol ProgressHUDDelegate {
    func startProgress()
    func stopProgress()
}

class RouteInputViewController: UIViewController, SearchViewDelegate, LocationInfoDataDelegate {
    
    var routeParams = RouteParams()
    var routeInfoVC: RouteInfoViewController?
    var routeInfodelegate: RouteInfoDelegate?
    var progressDelegate: ProgressHUDDelegate?
    
    var countQueue = 0
    
    let viewHeight: CGFloat = 222
    let contentViewPadding: CGFloat = 16
    let buttonPointSize: CGFloat = 15
    lazy var buttonWidth: CGFloat = buttonPointSize * 4 / 3
    
    let userInputTitles = [
        "출발지 입력".localized(),
        "출발 대여소 지도에서 선택".localized(),
        "도착지 입력".localized(),
        "도착 대여소 지도에서 선택".localized()
    ]
    lazy var userInputs = [oriInput, oriRantalStationInput, dstInput, dstRantalStationInput]
    lazy var locationInputs = [oriInput, dstInput]
    lazy var rantalInputs = [oriRantalStationInput, dstRantalStationInput]
    
    weak var mapVC: MapViewController?
    
    // MARK: UI
    lazy var oriInput = UIButton().then {
        $0.tag = 0
    }
    lazy var oriRantalStationInput = UIButton().then {
        $0.tag = 1
    }
    lazy var dstInput = UIButton().then {
        $0.tag = 2
    }
    lazy var dstRantalStationInput = UIButton().then {
        $0.tag = 3
    }
    lazy var path0 = NMFPath().then {
        $0.color = .gray
        $0.width = 8
    }
    lazy var path1 = NMFPath().then {
        $0.color = .blue
        $0.width = 3
    }
    lazy var path2 = NMFPath().then {
        $0.color = .gray
        $0.width = 8
    }
    lazy var pathes = [path0, path1, path2]
    
    lazy var swapButton = UIButton().then {
        $0.setImage(UIImage(systemName: "arrow.up.arrow.down"), for: .normal)
        $0.backgroundColor = .white
        $0.setPointSize(pointSize: 12)
        $0.tintColor = .themeGreyscaled
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 20
        $0.addTarget(self, action: #selector(swapButtonClicked), for: .touchUpInside)
    }
    lazy var oriCancelButton = UIButton().then {
        $0.tag = 0
        $0.setImage(UIImage(systemName: "xmark"), for: .normal)
        $0.setPointSize(pointSize: 15)
        $0.tintColor = .themeGreyscaled
        $0.addTarget(self, action: #selector(cancelButtonClicked), for: .touchUpInside)
    }
    lazy var dstCancelButton = UIButton().then {
        $0.tag = 1
        $0.setImage(UIImage(systemName: "xmark"), for: .normal)
        $0.setPointSize(pointSize: 15)
        $0.tintColor = .themeGreyscaled
        $0.addTarget(self, action: #selector(cancelButtonClicked), for: .touchUpInside)
    }
    lazy var findButton = UIButton().then {
        $0.setTitle("길찾기".localized(), for: .normal)
        $0.titleLabel?.font = .boldThemeFont(ofSize: 15)
        
        $0.backgroundColor = .themeMain
        $0.layer.cornerRadius = 15
        $0.addTarget(self, action: #selector(findButtonClicked), for: .touchUpInside)
    }

    // MARK: Events
    @objc
    func swapButtonClicked() {
        print(#function)
        routeParams.swap()
        Marker.shared.swapRouteParams()
        for tag in [0, 2] {
            if let tmp = routeParams.allCases[tag] as? PlaceDetail {
                setTitle(of: userInputs[tag], with: tmp.road_address_name)
            } else {
                setInitailTitle(of: userInputs[tag])
            }
        }
        for tag in [1, 3] {
            if let tmp = routeParams.allCases[tag] as? StationStatus {
                setTitle(of: userInputs[tag], with: tmp.stationName)
            } else {
                setInitailTitle(of: userInputs[tag])
            }
        }
    }

    @objc
    func cancelButtonClicked(_ sender: UIButton) {
        self.clearRoute()
        routeInfodelegate?.hideRouteInfoButton()
        userInputs.filter({ $0.tag / 2 == sender.tag }).forEach { userInput in
            if userInput.tag == 0 {
                routeParams.origin = nil
            } else if userInput.tag == 1 {
                routeParams.originStation = nil
            } else if userInput.tag == 2 {
                routeParams.destination = nil
            } else if userInput.tag == 3 {
                routeParams.destinationStation = nil
            }
            setInitailTitle(of: userInput)
            Marker.shared.allCases[userInput.tag].mapView = nil
        }
    }
   
    @objc
    func findButtonClicked(_ sender: UIButton) {
        if !routeParams.didCompleteFilling {
            presentAlert(title: "검색 실패", message: "모든 정보를 입력해주세요.", okTitle: "돌아가기")
        } else {
            if countQueue != 0 { return }
            progressDelegate?.startProgress()
            clearRoute()
            for phase in 0...2 {
                showRouteArray(phase: phase)
            }
            mapVC!.stationButtonToggled(mapVC!.stationToggleButton)
        }
    }
    
    func presentAlert(title: String, message: String, okTitle: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: okTitle, style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: false)
    }
    
    //MARK: Route
    func clearRoute() {
        pathes.forEach({ $0.mapView = nil })
    }
    
    func makeRequestURL(phase: Int) -> String {
        var params: ORRequest.Parameter
        if phase == 0 {
            params = ORRequest.Parameter(start: routeParams.origin!.coordinate,
                                         end: routeParams.originStation!.coordinate,
                                         profile: .foot_walking)
        } else if phase == 1 {
            params = ORRequest.Parameter(start: routeParams.originStation!.coordinate,
                                         end: routeParams.destinationStation!.coordinate,
                                         profile: .cycling_regular)
        } else if phase == 2 {
            params = ORRequest.Parameter(start: routeParams.destinationStation!.coordinate,
                                         end: routeParams.destination!.coordinate,
                                         profile: .foot_walking)
        } else {
            return ""
        }
        return ORRequest.makeRequestURL(params: params)
    }
    
    func showRouteArray(phase: Int) {
        let requestURL = self.makeRequestURL(phase: phase)
        
        print("Request URL : ", requestURL)
        
        AF.request(requestURL,
                   method: .get,
                   parameters: nil,
                   headers: nil
        ).responseJSON { response in
            switch response.result {
            case .success(let jsonData):
                do {
                    let json = try JSONSerialization.data(withJSONObject: jsonData, options: .prettyPrinted)
                    let result = try JSONDecoder().decode(ORResponse.self, from: json)
                    print("===PHASE \(phase) ===")
                    print("총 거리 :  \(result.distance)")
                    print("총 시간 :  \(result.duration)")
                    self.drawRoute(with: result.coordinates, phase: phase)
                    self.routeInfoVC!.setData(phase: phase, response: result)
                    self.routeInfodelegate?.showRouteInfo()
                    self.countQueue += 1
                    if self.countQueue == 3 {
                        self.progressDelegate?.stopProgress()
                        self.countQueue = 0
                    }
                } catch(let error) {
                    print(error.localizedDescription)
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func drawRoute(with doublepoints: [[Double]], phase: Int) {
        let points = doublepoints.toNMGLatLngArray()
        self.pathes[phase].path = NMGLineString(points: points)
        self.pathes[phase].mapView = self.mapVC?.mapView
    }
    
    func getStationStatus(stationStatus: StationStatus, tag: Int) {
        if tag  == 1 {
            setTitle(of: oriRantalStationInput, with: stationStatus.stationName)
            routeParams.originStation = stationStatus
        } else {
            setTitle(of: dstRantalStationInput, with: stationStatus.stationName)
            routeParams.destinationStation = stationStatus
        }
    }

    // MARK: Set UserInput Title
    func setInitailTitle(of button: UIButton) {
        button.setTitle(userInputTitles[button.tag], for: .normal)
        button.setTitleColor(.themeGreyscaled, for: .normal)
    }
    func setTitle(of button: UIButton, with title: String) {
        button.setTitle(title, for: .normal)
        button.setTitleColor(.black, for: .normal)
    }
    
    lazy var oriStackView = UIStackView().then {
        $0.addArrangedSubview(oriInput)
        $0.addArrangedSubview(oriRantalStationInput)
        $0.axis = .vertical
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.spacing = 3
    }
    lazy var dstStackView = UIStackView().then {
        $0.addArrangedSubview(dstInput)
        $0.addArrangedSubview(dstRantalStationInput)
        $0.axis = .vertical
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.spacing = 3
    }
    lazy var textStackView = UIStackView().then {
        $0.addArrangedSubview(oriStackView)
        $0.addArrangedSubview(dstStackView)
        $0.axis = .vertical
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.spacing = 13
    }

    lazy var contentView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 15
        $0.addSubview(textStackView)
        $0.addSubview(swapButton)
        $0.addSubview(oriCancelButton)
        $0.addSubview(dstCancelButton)
        $0.addSubview(findButton)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setContstraints()
        setTextFields()
}
    
    func setContstraints() {
        view.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(222)
        }
        textStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(16)
            make.height.equalTo(155)
            make.left.right.equalToSuperview().inset(contentViewPadding)
        }
        swapButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(textStackView)
            make.size.equalTo(32)
        }
        
        oriCancelButton.snp.makeConstraints { make in
            make.centerX.equalTo(textStackView.snp.right).inset(20)
            make.centerY.equalTo(oriInput.snp.centerY)
        }
        dstCancelButton.snp.makeConstraints { make in
            make.centerX.equalTo(textStackView.snp.right).inset(20)
            make.centerY.equalTo(dstInput.snp.centerY)
        }
        userInputs.forEach { textField in
            textField.snp.makeConstraints { make in
                make.height.equalTo(34)
            }
        }
        findButton.snp.makeConstraints { make in
            make.top.equalTo(textStackView.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(contentViewPadding)
            make.bottom.equalTo(contentView.snp.bottom).inset(8)
        }
    }
    
    func setTextFields() {
        userInputs.forEach { userInput in
            userInput.backgroundColor = .grayLevel10
            setInitailTitle(of: userInput)
            userInput.titleLabel?.font = .themeFont(ofSize: 13)
            userInput.contentHorizontalAlignment = .left
            userInput.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
            userInput.layer.cornerRadius = 5
        }
        locationInputs.forEach { userInput in
            userInput.setTitleColor(.grayLevel50, for: .normal)
            userInput.setTitleColor(.grayLevel20, for: .highlighted)
            userInput.addTarget(self, action: #selector(showSearchView), for: .touchUpInside)
        }
        rantalInputs.forEach { userInput in
            userInput.setTitleColor(.grayLevel20, for: .normal)
            userInput.isEnabled = false
        }
    }
    
    // MARK: Delegate
    func sendPlaceDetails(targetTag tag: Int, _ placeDetail: PlaceDetail) {
        guard let button = locationInputs.filter({ $0.tag == tag }).first else { return }
        setTitle(of: button, with: placeDetail.road_address_name)
        if tag == 0 {
            routeParams.origin = placeDetail
            mapVC!.makeRouteparamMarker(coor: placeDetail.coordinate, for: .origin)
        } else {
            routeParams.destination = placeDetail
            mapVC!.makeRouteparamMarker(coor: placeDetail.coordinate, for: .destination)
        }
        mapVC?.updateMap(to: placeDetail.coordinate)
    }
    
    @objc
    func showSearchView(_ sender: UIButton) {
        print(sender)
        
        let vc = SearchViewController()
        
        vc.delegate = self
        vc.callBackTag = sender.tag
        
        let nav = UINavigationController(rootViewController: vc)
        
        nav.modalPresentationStyle = .fullScreen
        
        present(nav, animated: false, completion: nil)
    }
}
