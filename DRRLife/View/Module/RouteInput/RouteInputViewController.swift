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
    let height: CGFloat = 500
    let textFieldPadding: CGFloat = 50
    let buttonPointSize: CGFloat = 15
    lazy var buttonWidth: CGFloat = buttonPointSize * 4 / 3
    
    
    
    lazy var oriInput = UIButton().then {
        $0.tag = 1
        $0.setTitle("출발지 입력".localized(), for: .normal)
    }
    lazy var oriRantalShopInput = UIButton().then {
        $0.tag = 2
        $0.setTitle("출발지 대여소".localized(), for: .normal)
    }
    lazy var dstInput = UIButton().then {
        $0.tag = 3
        $0.setTitle("도착지 입력".localized(), for: .normal)
    }
    lazy var dstRantalShopInput = UIButton().then {
        $0.tag = 4
        $0.setTitle("도착지 대여소".localized(), for: .normal)
    }
    lazy var userInputs = locationInputs + rantalInputs
    lazy var locationInputs = [oriInput, dstInput]
    lazy var rantalInputs = [oriRantalShopInput, dstRantalShopInput]
    
    lazy var swapButton = UIButton().then {
        $0.setImage(UIImage(systemName: "arrow.up.arrow.down"), for: .normal)
        $0.setPointSize(pointSize: 15)
        $0.tintColor = .themeGreyscaled
    }
    lazy var oriCancelButton = UIButton().then {
        $0.setImage(UIImage(systemName: "xmark"), for: .normal)
        $0.setPointSize(pointSize: 15)
        $0.tintColor = .themeGreyscaled
    }
    lazy var dstCancelButton = UIButton().then {
        $0.setImage(UIImage(systemName: "xmark"), for: .normal)
        $0.setPointSize(pointSize: 15)
        $0.tintColor = .themeGreyscaled
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

    lazy var bgView = UIView().then {
        $0.backgroundColor = .white
        $0.addSubview(textStackView)
        $0.addSubview(swapButton)
        $0.addSubview(oriCancelButton)
        $0.addSubview(dstCancelButton)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setContstraints()
        setTextFields()
    }
    
    func setContstraints() {
        view.addSubview(bgView)
        
        bgView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(181)
        }
        textStackView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(13)
            make.left.right.equalToSuperview().inset(textFieldPadding)
        }
        swapButton.snp.makeConstraints { make in
            make.left.equalToSuperview().inset((textFieldPadding - buttonWidth) / 2)
            make.centerY.equalToSuperview()
        }
        
        oriCancelButton.snp.makeConstraints { make in
            make.centerX.equalTo(textStackView.snp.right).offset(textFieldPadding / 2)
            make.centerY.equalTo(oriInput.snp.centerY)
        }
        dstCancelButton.snp.makeConstraints { make in
            make.centerX.equalTo(textStackView.snp.right).offset(textFieldPadding / 2)
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
            userInput.backgroundColor = .themeTextFieldBG
            userInput.titleLabel?.font = .systemFont(ofSize: 13)
            userInput.contentHorizontalAlignment = .left
            userInput.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
            userInput.layer.cornerRadius = 5
        }
        locationInputs.forEach { userInput in
            userInput.setTitleColor(.themeTextFieldPlaceholder, for: .normal)
            userInput.setTitleColor(.themeTextFieldDisabledPlaceholder, for: .highlighted)
            userInput.addTarget(self, action: #selector(showSearchView), for: .touchUpInside)
        }
        rantalInputs.forEach { userInput in
            userInput.setTitleColor(.themeTextFieldDisabledPlaceholder, for: .normal)
            userInput.isEnabled = false
        }
    }
    
    // MARK: Delegate
    func sendPlaceDetails(targetTag tag: Int, _ placeDetails: [PlaceDetail]) {
        guard let button = locationInputs.filter({ $0.tag == tag }).first else { return }
        guard let placeDetail = placeDetails.first else { return }
        button.setTitle(placeDetail.road_address_name, for: .normal)
        button.setTitleColor(.black, for: .normal)
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
