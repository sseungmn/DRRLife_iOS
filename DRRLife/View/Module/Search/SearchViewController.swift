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
import Moya

protocol SearchViewDelegate {
    func sendPlaceDetails(targetTag tag: Int, _ placeDetail: PlaceDetail)
}

class SearchViewController: UIViewController {
    
    var callBackTag = -1
    let maxCount = 15
    let locationManager = CLLocationManager()
    let searchBar = UISearchBar()
    let tableView = UITableView()
    var delegate: SearchViewDelegate?
    
    var currentCoordinate: Coordinate {
        return makeCurrentCoordinate() ?? Coordinate()
    }
    var itemCount: Int {
        return placeDetails.count > maxCount ? maxCount : placeDetails.count
    }
    var placeDetails = [PlaceDetail]()
    
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
        cell.setData(row: self.placeDetails[indexPath.row])
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let placeDetail = placeDetails[indexPath.row]
        delegate?.sendPlaceDetails(targetTag: callBackTag, placeDetail)
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
        
        let query =  searchText
        let x = currentCoordinate.lng.toString
        let y = currentCoordinate.lat.toString
        
        let provider = MoyaProvider<KLRequest>()
        provider.request(.location(query: query, x: x, y: y)) {
            [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                do {
                    try print(response.mapJSON())
                    let data = try JSONDecoder().decode(KLResponse.self, from: response.data)
                    self.placeDetails = data.documents
                    print("===== 검색 결과 '\(self.itemCount)개'")
                } catch {
                    print(error.localizedDescription)
                }
                self.tableView.reloadData()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    // MARK: Clear
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.clearResults()
    }
    func clearResults() {
        self.placeDetails.removeAll()
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
