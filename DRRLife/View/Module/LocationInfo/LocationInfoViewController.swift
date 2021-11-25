//
//  LocationInfoViewController.swift
//  DRRLife
//
//  Created by OHSEUNGMIN on 2021/11/22.
//

import UIKit
import Then
import SnapKit

class LocationInfoViewController: UIViewController {
    var stationStatus : StationStatus?
    
    lazy var stationNameLabel = UILabel().then {
        $0.font = .boldSystemFont(ofSize: 24)
        $0.text = stationStatus?.stationName ?? "가락시장역 3번 출구 대여소"
        $0.textColor = .themeMain
        $0.highlight(searchText: "대여소")
    }
    
    lazy var sepView = UIView().then {
        $0.backgroundColor = .themeGreyscaled
    }
    
    lazy var oriButton = UIButton().then {
        print("oriButton Setting")
        $0.backgroundColor = .white
        
        $0.layer.cornerRadius = 15
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.themeMain.cgColor
        
        $0.setTitle("출발 대여소".localized(), for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 13)
        $0.setTitleColor(.themeMain, for: .normal)
    }
    lazy var dstButton = UIButton().then {
        print("dstButton Setting")
        $0.backgroundColor = .themeMain
        
        $0.layer.cornerRadius = 15
        
        $0.setTitle("도착 대여소".localized(), for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 13)
        $0.setTitleColor(.white, for: .normal)
    }
    lazy var contentView = UIView().then {
        print("ContentView Setting")
        $0.backgroundColor = .white
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 15
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setContraints()
    }
    func setContraints() {
        view.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        contentView.addSubview(stationNameLabel)
        stationNameLabel.snp.makeConstraints { make in
            make.top.left.equalToSuperview().inset(20)
        }
        
        contentView.addSubview(sepView)
        sepView.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(76)
            make.height.equalTo(1)
            make.left.right.equalToSuperview()
        }
        
        contentView.addSubview(oriButton)
        oriButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(28)
            make.right.equalToSuperview().inset(128)
            make.width.equalTo(100)
            make.height.equalTo(40)
        }
        contentView.addSubview(dstButton)
        dstButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(28)
            make.right.equalToSuperview().inset(20)
            make.width.equalTo(100)
            make.height.equalTo(40)
        }
    }
}
