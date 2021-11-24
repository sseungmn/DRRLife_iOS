//
//  RouteInputViewController.swift
//  DRRLife
//
//  Created by OHSEUNGMIN on 2021/11/22.
//

import UIKit
import SnapKit
import Then

class RouteInputViewController: UIViewController, PassDataDelegate {
    let viewHeight: CGFloat = 187
    let textFieldPadding: CGFloat = 16
    let buttonPointSize: CGFloat = 15
    lazy var buttonWidth: CGFloat = buttonPointSize * 4 / 3
    
    var mapView: MapViewController?
    
    lazy var oriInput = UIButton().then {
        $0.tag = 0
    }
    lazy var oriRantalShopInput = UIButton().then {
        $0.tag = 1
    }
    lazy var dstInput = UIButton().then {
        $0.tag = 2
    }
    lazy var dstRantalShopInput = UIButton().then {
        $0.tag = 3
    }
    let userInputTitles = [
        "출발지 입력".localized(),
        "출발지 대여소".localized(),
        "도착지 입력".localized(),
        "도착지 대여소".localized()
    ]
    lazy var userInputs = locationInputs + rantalInputs
    lazy var locationInputs = [oriInput, dstInput]
    lazy var rantalInputs = [oriRantalShopInput, dstRantalShopInput]
    
    lazy var swapButton = UIButton().then {
        $0.setImage(UIImage(systemName: "arrow.up.arrow.down"), for: .normal)
        $0.backgroundColor = .white
        $0.setPointSize(pointSize: 15)
        $0.tintColor = .themeGreyscaled
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 20
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
    func setInitailTitle(button: UIButton) {
        button.setTitle(userInputTitles[button.tag], for: .normal)
    }
    
    @objc
    func cancelButtonClicked(_ sender: UIButton) {
        Marker.shared.locationMarker.mapView = nil
        userInputs.filter({ $0.tag / 2 == sender.tag }).forEach { userInput in
            setInitailTitle(button: userInput)
            Marker.shared.allCases[userInput.tag].mapView = nil
        }
    }
    
    lazy var oriStackView = UIStackView().then {
        $0.addArrangedSubview(oriInput)
        $0.addArrangedSubview(oriRantalShopInput)
        $0.axis = .vertical
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.spacing = 3
    }
    lazy var dstStackView = UIStackView().then {
        $0.addArrangedSubview(dstInput)
        $0.addArrangedSubview(dstRantalShopInput)
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
        $0.layer.cornerRadius = 5
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
//        view.layer.shadowOffset = CGSize(width: 10, height: 10)
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
            setInitailTitle(button: userInput)
            userInput.titleLabel?.font = .systemFont(ofSize: 13)
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
    func sendPlaceDetails(targetTag tag: Int, _ placeDetails: [PlaceDetail]) {
        guard let button = locationInputs.filter({ $0.tag == tag }).first else { return }
        guard let placeDetail = placeDetails.first else { return }
        button.setTitle(placeDetail.road_address_name, for: .normal)
        button.setTitleColor(.black, for: .normal)
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
