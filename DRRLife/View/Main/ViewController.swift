//
//  ViewController.swift
//  DRRLife
//
//  Created by OHSEUNGMIN on 2021/11/20.
//

import UIKit
import Then
import SnapKit
import Alamofire

class ViewController: UIViewController {
    lazy var routeInputVC = RouteInputViewController()
    lazy var mapVC = MapViewController()
    lazy var locationInfoVC = LocationInfoViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setInnerView()
        setConstraints()
        routeInputVC.view.isHidden = false
        
        showLocationInfo()
    }
    
    func requestRantalShopList() {
        RequestURL.parameters["START_INDEX"] = 1
        RequestURL.parameters["END_INDEX"] = 1000
        AF.request(RequestURL.requestURL,
                   method: .get,
                   parameters: nil,
                   headers: nil
        ).responseJSON(completionHandler: { response in
            switch response.result {
            case .success(let jsonData):
                print(jsonData)
            case .failure(let error):
                print(error.localizedDescription)
            }
        })
    }
    
    func setInnerView() {
        self.add(mapVC)
        self.add(locationInfoVC)
        self.add(routeInputVC)
        routeInputVC.mapView = mapVC
    }
    
    func setConstraints() {
        routeInputVC.view.snp.makeConstraints { make in
            make.top.equalTo(view.safeArea.top)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(200)
        }
        
        mapVC.view.snp.makeConstraints { make in
            make.top.left.right.bottom.equalToSuperview()
        }
        locationInfoVC.view.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
        }
    }
    
    func showLocationInfo() {
        mapVC.view.snp.updateConstraints { make in
            make.bottom.equalToSuperview().inset(200)
        }
        locationInfoVC.view.snp.makeConstraints { make in
            make.height.equalTo(200)
        }
    }
}
