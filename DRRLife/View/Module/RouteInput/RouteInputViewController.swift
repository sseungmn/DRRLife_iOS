//
//  RouteInputViewController.swift
//  DRRLife
//
//  Created by OHSEUNGMIN on 2021/11/22.
//

import UIKit
import SnapKit
import Then

class RouteInputViewController: UIViewController {
    let height: CGFloat = 500
    let textFieldPadding: CGFloat = 50
    let buttonPointSize: CGFloat = 15
    lazy var buttonWidth: CGFloat = buttonPointSize * 4 / 3
    
    lazy var oriTextField = UITextField().then {
        $0.placeholder = "출발지 입력".localized()
    }
    lazy var oriRantalShopTextField = UITextField().then {
        $0.placeholder = "출발지 대여소".localized()
        $0.isEnabled = false
    }
    lazy var dstTextField = UITextField().then {
        $0.placeholder = "도착지 입력".localized()
    }
    lazy var dstRantalShopTextField = UITextField().then {
        $0.placeholder = "도착지 대여소".localized()
        $0.isEnabled = false
    }
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
        $0.addArrangedSubview(oriTextField)
        $0.addArrangedSubview(oriRantalShopTextField)
        $0.axis = .vertical
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.spacing = 3
    }
    lazy var dstStackView = UIStackView().then {
        $0.addArrangedSubview(dstTextField)
        $0.addArrangedSubview(dstRantalShopTextField)
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
            make.centerY.equalTo(oriTextField.snp.centerY)
        }
        dstCancelButton.snp.makeConstraints { make in
            make.centerX.equalTo(textStackView.snp.right).offset(textFieldPadding / 2)
            make.centerY.equalTo(dstTextField.snp.centerY)
        }
        
        [oriTextField, oriRantalShopTextField, dstTextField, dstRantalShopTextField].forEach { textField in
            textField.backgroundColor = .themeTextFieldBG
            textField.layer.cornerRadius = 5
            textField.addLeftPadding()
            textField.snp.makeConstraints { make in
                make.height.equalTo(34)
            }
        }
        [oriTextField, dstTextField].forEach { textField in
            textField.setPlaceholderColor(.themeTextFieldPlaceholder)
        }
        [oriRantalShopTextField, dstRantalShopTextField].forEach { textField in
            textField.setPlaceholderColor(.themeTextFieldDisabledPlaceholder)
        }
    }
}
