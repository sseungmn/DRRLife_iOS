//
//  RouteInputViewController.swift
//  DRRLife
//
//  Created by OHSEUNGMIN on 2021/11/22.
//

import UIKit
import SnapKit
import Then

class RouteInputViewController: UIViewController, PlaceDetailDelegate {
    var routeParams = RouteParams()
    
    let viewHeight: CGFloat = 187
    let textFieldPadding: CGFloat = 16
    let buttonPointSize: CGFloat = 15
    lazy var buttonWidth: CGFloat = buttonPointSize * 4 / 3
    
    var mapView: MapViewController?
    
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
    let userInputTitles = [
        "출발지 입력".localized(),
        "출발 대여소 지도에서 선택".localized(),
        "도착지 입력".localized(),
        "도착 대여소 지도에서 선택".localized()
    ]
    lazy var userInputs = [oriInput, oriRantalStationInput, dstInput, dstRantalStationInput]
    lazy var locationInputs = [oriInput, dstInput]
    lazy var rantalInputs = [oriRantalStationInput, dstRantalStationInput]
    
    lazy var swapButton = UIButton().then {
        $0.setImage(UIImage(systemName: "arrow.up.arrow.down"), for: .normal)
        $0.backgroundColor = .white
        $0.setPointSize(pointSize: 15)
        $0.tintColor = .themeGreyscaled
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 20
        $0.addTarget(self, action: #selector(swapButtonClicked), for: .touchUpInside)
    }
    @objc
    func swapButtonClicked() {
        print(#function)
        routeParams.swap()
        for tag in [0, 2] {
            if let tmp = routeParams.allCases[tag] as? PlaceDetail {
                setTitle(of: userInputs[tag], with: tmp.road_address_name)
            } else {
                setInitailTitle(of: userInputs[tag])
            }
        }
        for tag in [1, 3] {
            if let tmp = routeParams.allCases[tag] as? Station {
                setTitle(of: userInputs[tag], with: tmp.station_name)
            } else {
                setInitailTitle(of: userInputs[tag])
            }
        }
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
    @objc
    func cancelButtonClicked(_ sender: UIButton) {
        Marker.shared.locationMarker.mapView = nil
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

    // MARK: Set UserInput Title
    func setInitailTitle(of button: UIButton) {
        button.setTitle(userInputTitles[button.tag], for: .normal)
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
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setContstraints()
        setTextFields()
        view.clipsToBounds = false
        view.layer.shadowRadius = 5
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.3
    }
    
    func setContstraints() {
        view.addSubview(contentView)
        
        contentView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(viewHeight)
        }
        textStackView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(16)
            make.left.right.equalToSuperview().inset(textFieldPadding)
        }
        swapButton.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(40)
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
        } else {
            routeParams.destination = placeDetail
        }
        mapView?.updateMap(to: placeDetail.coordinate)
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
