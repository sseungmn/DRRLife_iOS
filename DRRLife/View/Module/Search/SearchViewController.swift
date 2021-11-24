//
//  SearchViewController.swift
//  DRRLife
//
//  Created by OHSEUNGMIN on 2021/11/23.
//

import UIKit
import Alamofire
import SnapKit
import Then
import CoreLocation

protocol PassDataDelegate {
    func sendPlaceDetails(targetTag tag: Int, _ placeDetails: [PlaceDetail])
}

class SearchViewController: UIViewController {
    
    var callBackTag = -1
    let maxCount = 15
    let locationManager = CLLocationManager()
    let searchBar = UISearchBar()
    let tableView = UITableView()
    var delegate: PassDataDelegate?
    
    let headers: HTTPHeaders = [
        "Authorization": "KakaoAK \(Bundle.main.KakaoLocal)"
    ]
    
    lazy var parameters: [String: Any] = [
        "query": "",
        "x": "",
        "y": "",
        "page": 1,
        "size": maxCount,
        "sort": "accuracy"
    ]
    
    var currentCoordinate: Coordinate {
        return makeCurrentCoordinate() ?? Coordinate()
    }
    var itemCount: Int {
        return places.count > maxCount ? maxCount : places.count
    }
    var places = [KLResponse.Place]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setSearchBar()
        registerXib()
        setTableView()
    }
}

// MARK: - Table
extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func registerXib() {
        let nibName = UINib(nibName: SearchTableViewCell.identifier, bundle: nil)
        tableView.register(nibName, forCellReuseIdentifier: SearchTableViewCell.identifier)
    }
    
    func setTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemCount
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UIScreen.main.bounds.height / 12
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchTableViewCell.identifier, for: indexPath) as? SearchTableViewCell else {
            return UITableViewCell()
        }
        cell.setData(row: self.places[indexPath.row])
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = places[indexPath.row]
        let placeDetail = row.makePlaceDetail()
        delegate?.sendPlaceDetails(targetTag: callBackTag, [placeDetail])
        self.dismiss(animated: false, completion: nil)
    }
}

// MARK: - Search
extension SearchViewController: UISearchBarDelegate {
    func setSearchBar() {
        searchBar.delegate = self
        searchBar.placeholder = "검색".localized()
        
        let backButton = UIBarButtonItem(
            image: UIImage(systemName: "lessthan"),
            style: .plain,
            target: self,
            action: #selector(backButtonClicked)
        )
        navigationItem.leftBarButtonItem = backButton
        searchBar.setImage(UIImage(), for: .search, state: .normal)
        searchBar.searchTextField.backgroundColor = .clear
        navigationItem.titleView = searchBar
        searchBar.becomeFirstResponder()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchBar.layer.addBorder([.bottom], color: .grayLevel20, borderWidth: 1.0)
    }
    
    @objc
    func backButtonClicked(_ sender: UIBarButtonItem) {
        self.dismiss(animated: false, completion: nil)
    }
        
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count <= 0 { self.clearResults() }
        
        parameters["query"] = searchText
        parameters["x"] = currentCoordinate.lng
        parameters["y"] = currentCoordinate.lat
        
        AF.request("https://dapi.kakao.com/v2/local/search/keyword.json",
                   method: .get,
                   parameters: self.parameters, headers: self.headers
        ).responseJSON(completionHandler: { response in
            switch response.result {
            case .success(let jsonData):
                print(jsonData)
                print("===== 검색 성공 '\(searchText)' =====")
                do {
                    let json = try JSONSerialization.data(withJSONObject: jsonData, options: .prettyPrinted)
                    let result = try JSONDecoder().decode(KLResponse.self, from: json)
                    self.places = result.documents
                    print("===== 검색 결과 '\(self.itemCount)개'")
                    for place in self.places {
                        print(place)
                    }
                    
                } catch(let error) {
                    print(error.localizedDescription)
                }
                self.tableView.reloadData()
            case .failure(let error):
                print(error.localizedDescription)
            }
        })
    }
    
    // MARK: Clear
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.clearResults()
    }
    func clearResults() {
        self.places.removeAll()
        tableView.reloadData()
    }
}

extension SearchViewController: CLLocationManagerDelegate {
    
    func setDelegate() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
    }
    
    func checkService() -> Bool {
        if CLLocationManager.locationServicesEnabled() {
            print("위치 서비스 ON")
            locationManager.startUpdatingLocation()
            return true
        } else {
            print("위치 서비스 OFF")
            return false
        }
    }
    
    func makeCurrentCoordinate() -> Coordinate? {
        guard let coor = locationManager.location?.coordinate else { return nil }
        return Coordinate(lat: coor.latitude, lng: coor.longitude)
    }
}
