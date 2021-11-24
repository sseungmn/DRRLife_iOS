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
    var stations = [StationInfo]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setInnerView()
        setConstraints()
        routeInputVC.view.isHidden = false
        
//        showLocationInfo()
        stations = getRantalStaionList(count: 2000)
        for station in stations {
            print(station.stationName)
        }
    }
    
    func getRantalStaionList(count: Int) -> [StationInfo] {
        var tmpInfoArray = [StationInfo]()
        var start = 1
        var end = count > 1000 ? 1000 : count
        
        while start <= end {
            guard let results = requestRantalStationList(start, end) else { break }
            tmpInfoArray.append(contentsOf: results)
            start += 1000
            end = end + 1000 <= count ? end + 1000 : count
        }
        
        return tmpInfoArray
    }
    
    func requestRantalStationList(_ start: Int, _ end: Int) -> [StationInfo]? {
        
        RequestURL.parameters["START_INDEX"] = start
        RequestURL.parameters["END_INDEX"] = end
        print("\(start)~\(end)")
        var tmpInfoArray = [StationInfo]()
        
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
                    for station in result.rentBikeStatus.row {
                        print(station.stationName)
                    }
                    tmpInfoArray.append(contentsOf: result.rentBikeStatus.row)
                    
                } catch(let error) {
                    print(error.localizedDescription)
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        })
        return tmpInfoArray
    }
    
    func setInnerView() {
        self.add(mapVC)
        
        self.add(locationInfoVC)
        locationInfoVC.view.layer.masksToBounds = true
        locationInfoVC.view.layer.cornerRadius = 5
        
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
            make.bottom.equalToSuperview().inset(250)
        }
        locationInfoVC.view.snp.makeConstraints { make in
            make.height.equalTo(260)
        }
    }
}
