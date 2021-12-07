//
//  LocationInfoViewController.swift
//  DRRLife
//
//  Created by OHSEUNGMIN on 2021/11/22.
//

import UIKit
import Then
import NMapsMap
import SnapKit

protocol LocationInfoDataDelegate {
    func getStationStatus(stationStatus: StationStatus, tag: Int)
}

class LocationInfoViewController: UIViewController {
    var stationStatus : StationStatus?
    weak var mapVC: MapViewController?
    
    lazy var stationNameLabel = UILabel().then {
        $0.font = .extraboldThemeFont(ofSize: 22)
        $0.textColor = .themeMain
        $0.textAlignment = .left
    }
    
    lazy var descriptionLabel = UILabel().then {
        $0.text = "현재 거치되어 있는 따릉이 대수".localized()
        $0.font = .themeFont(ofSize: 16)
        $0.textColor = .black
        $0.textAlignment = .left
    }
    lazy var parkingBikeTotCntLabel = UILabel().then {
        $0.font = .extraboldThemeFont(ofSize: 18)
        $0.textColor = .themeHighlight
    }
    
    lazy var sepView = UIView().then {
        $0.backgroundColor = .themeGreyscaled
    }
    
    lazy var oriRantalButton = UIButton().then {
        print("oriRantalButton Setting")
        $0.backgroundColor = .white
        
        $0.layer.cornerRadius = 15
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.themeMain.cgColor
        
        $0.setTitle("출발 대여소".localized(), for: .normal)
        $0.titleLabel?.font = .themeFont(ofSize: 10)
        $0.setTitleColor(.themeMain, for: .normal)
        $0.addTarget(self, action: #selector(setLocationButtonClicked), for: .touchUpInside)
    }
    lazy var dstRantalButton = UIButton().then {
        print("dstRantalButton Setting")
        $0.backgroundColor = .themeMain
        
        $0.layer.cornerRadius = 15
        
        $0.setTitle("도착 대여소".localized(), for: .normal)
        $0.titleLabel?.font = .themeFont(ofSize: 10)
        $0.setTitleColor(.white, for: .normal)
        $0.addTarget(self, action: #selector(setLocationButtonClicked), for: .touchUpInside)
    }
    lazy var contentView = UIView().then {
        print("ContentView Setting")
        $0.backgroundColor = .white
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 15
        
        $0.addSubview(stationNameLabel)
        $0.addSubview(descriptionLabel)
        $0.addSubview(parkingBikeTotCntLabel)
        $0.addSubview(sepView)
        $0.addSubview(oriRantalButton)
        $0.addSubview(dstRantalButton)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setContraints()
    }
    
    var delegate: LocationInfoDataDelegate?
    @objc
    func setLocationButtonClicked(_ sender: UIButton) {
        if sender == self.oriRantalButton {
            delegate?.getStationStatus(stationStatus: stationStatus!, tag: 1)
            MarkerManager.shared.originRantalMarker.mapView = nil
            mapVC?.makeParamMarker(coor: stationStatus!.coordinate, for: .originRantalStation)
        } else {
            delegate?.getStationStatus(stationStatus: stationStatus!, tag: 3)
            MarkerManager.shared.destinationRantalMarker.mapView = nil
            mapVC?.makeParamMarker(coor: stationStatus!.coordinate, for: .destinationRantalStation)
        }
    }
    
    func updateData() {
        stationNameLabel.text = stationStatus?.name
        parkingBikeTotCntLabel.text = stationStatus?.parkingBikeTotCnt
    }
    
    func setContraints() {
        view.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        stationNameLabel.snp.makeConstraints { make in
            make.top.left.equalToSuperview().inset(20)
            make.right.lessThanOrEqualToSuperview().inset(20)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(85)
            make.left.equalToSuperview().inset(20)
        }
        
        parkingBikeTotCntLabel.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(85)
            make.left.equalTo(descriptionLabel.snp.right).offset(8)
        }
        
        sepView.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(56)
            make.height.equalTo(1)
            make.left.right.equalToSuperview()
        }
        
        oriRantalButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(8)
            make.right.equalToSuperview().inset(110)
            make.width.equalTo(100)
            make.height.equalTo(40)
        }
        dstRantalButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(8)
            make.right.equalToSuperview().inset(12)
            make.width.equalTo(90)
            make.height.equalTo(40)
        }
    }
}
