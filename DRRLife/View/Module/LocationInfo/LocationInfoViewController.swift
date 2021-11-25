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
        $0.font = .extraboldThemeFont(ofSize: 26)
        $0.textColor = .themeMain
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
        $0.titleLabel?.font = .themeFont(ofSize: 13)
        $0.setTitleColor(.themeMain, for: .normal)
        $0.addTarget(self, action: #selector(setLocationButtonClicked), for: .touchUpInside)
    }
    lazy var dstButton = UIButton().then {
        print("dstButton Setting")
        $0.backgroundColor = .themeMain
        
        $0.layer.cornerRadius = 15
        
        $0.setTitle("도착 대여소".localized(), for: .normal)
        $0.titleLabel?.font = .themeFont(ofSize: 13)
        $0.setTitleColor(.white, for: .normal)
        $0.addTarget(self, action: #selector(setLocationButtonClicked), for: .touchUpInside)
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
    
    var delegate: LocationInfoDataDelegate?
    @objc
    func setLocationButtonClicked(_ sender: UIButton) {
        if sender == self.oriButton {
            delegate?.getStationStatus(stationStatus: stationStatus!, tag: 1)
            Marker.shared.oriRantalMarker.mapView = nil
            mapVC?.makeStationMarker(station: stationStatus!, for: .originRantalStation)
        } else {
            delegate?.getStationStatus(stationStatus: stationStatus!, tag: 3)
            Marker.shared.dstRantalMarker.mapView = nil
            mapVC?.makeStationMarker(station: stationStatus!, for: .destinationRantalStation)
        }
    }
    
    func updateData() {
        stationNameLabel.text = stationStatus?.stationName
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
