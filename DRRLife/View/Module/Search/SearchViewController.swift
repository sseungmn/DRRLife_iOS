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
    func sendPlaceDetails(_: [PlaceDetail])
}

class SearchViewController: UIViewController {
    
    let maxCount = 15
    let locationManager = CLLocationManager()
    let searchController = UISearchController(searchResultsController: nil)
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
        "sort": "distance"
    ]
    
    var currentCoordinate: Coordinate {
        return makeCurrentCoordinate() ?? Coordinate()
    }
    var itemCount: Int = 0 {
        didSet(oldValue) {
            if itemCount > maxCount { itemCount = maxCount }
        }
    }
    var places = [Place]()
    
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
        delegate?.sendPlaceDetails([placeDetail])
        self.dismiss(animated: false, completion: nil)
    }
}

// MARK: - Search
extension SearchViewController: UISearchBarDelegate, UISearchResultsUpdating {
    func setSearchBar() {
        searchController.searchBar.delegate = self
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "검색"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    func updateSearchResults(for searchController: UISearchController) {
        if let text = searchController.searchBar.text {
            if text.count <= 0 { return }
            parameters["query"] = text
            parameters["x"] = currentCoordinate.x
            parameters["y"] = currentCoordinate.y
            
            AF.request("https://dapi.kakao.com/v2/local/search/keyword.json",
                       method: .get,
                       parameters: self.parameters, headers: self.headers
            ).responseJSON(completionHandler: { response in
                switch response.result {
                case .success(let jsonData):
                    print("===== 검색 성공 '\(text)' =====")
                    do {
                        let json = try JSONSerialization.data(withJSONObject: jsonData, options: .prettyPrinted)
                        let result = try JSONDecoder().decode(Response.self, from: json)
                        self.itemCount = result.meta.total_count
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
    }
    
    func searchBarIsEmpty() -> Bool {
        guard let text = searchController.searchBar.text else { return true }
        if text.count <= 0 { return true }
        return false
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
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
        return Coordinate(x: String(coor.longitude), y: String(coor.latitude))
    }
}
