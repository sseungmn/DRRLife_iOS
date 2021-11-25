//
//  Model.swift
//  DRRLife
//
//  Created by OHSEUNGMIN on 2021/11/23.
//

import Foundation
import NMapsMap
import Then

struct RequestURL {
    static private let url = "http://openapi.seoul.go.kr:8088"
    static var parameters: [String : Any] = [
        "KEY": Bundle.main.SeoulOpenData,
        "TYPE": "json",
        "SERVICE": "bikeList",
        "START_INDEX": 0,
        "END_INDEX": 0
        ]
    static var requestURL: String {
        return "\(url)/\(parameters["KEY"]!)/\(parameters["TYPE"]!)/\(parameters["SERVICE"]!)/\(parameters["START_INDEX"]!)/\(parameters["END_INDEX"]!)/"
    }
}

// StationInformation File
struct StationInformation {
    var stationNumber: String
    var stationName: String
    /// 자치구
    var region: String
    var address: String
    var stationLatitude: String
    var stationLongitude: String
    /// LCD Type 자전거 대수
    var LCDNumber: String
    /// QR Type 자전거 대수
    var QRNumber: String
    /// 대여 방법
    var rantalType: String
}

// SeoulOpenData Response
struct StationStatus {
    var stationName: String
    var rackTotCnt: Int
    var parkingBikeTotCnt: Int
    var coordinate: Coordinate
}

struct SODResponse: Codable {
    var rentBikeStatus: RentBikeStatus
    
    struct RentBikeStatus: Codable {
        var RESULT: Result
        var list_total_count: Int
        var row: [RantalStationStatus]
        
        struct Result: Codable {
            var CODE: String
            var MESSAGE: String
        }
        
        struct RantalStationStatus: Codable {
            var parkingBikeTotCnt: String
            var rackTotCnt: String
            var shared: String
            var stationId: String
            var stationLatitude: String
            var stationLongitude: String
            var stationName: String
            
            func makeStationDetail() -> StationStatus {
                return StationStatus(stationName: self.stationName.components(separatedBy: ["."]).last!,
                                     rackTotCnt: self.rackTotCnt.toInt(),
                                     parkingBikeTotCnt: self.parkingBikeTotCnt.toInt(),
                                     coordinate: Coordinate(lat: self.stationLatitude, lng: self.stationLongitude))
            }
        }
    }
    
}

typealias StationInfo = SODResponse.RentBikeStatus.RantalStationStatus

// MARK: - MAP
class Marker {
    static let shared = Marker()
    
    lazy var locationMarker = NMFMarker().then {
        $0.iconImage = NMF_MARKER_IMAGE_BLACK
        $0.iconTintColor = UIColor.red
        $0.width = 30
        $0.height = 40
    }
    lazy var allCases = [oriMarker, oriRantalMarker, dstMarker, dstRantalMarker]
    let oriMarker = NMFMarker()
    let oriRantalMarker = NMFMarker()
    let dstMarker = NMFMarker()
    let dstRantalMarker = NMFMarker()
    
    var stationMarkers = [NMFMarker]()
    
    func showStationMarkers(mapView: NMFMapView) {
        print("showStationMarkers for \(stationMarkers.count)개")
        self.stationMarkers.forEach { marker in
            marker.mapView = mapView
        }
    }
    func hideStationMarkers() {
        print("hideStationMarkers")
        self.stationMarkers.forEach { marker in
            marker.mapView = nil
        }
    }
}

// MARK: - MAP, RouteInput

/// Contain variables for using coordinate
struct Coordinate {
    /// *latitude*, and also can be *y*
    var lat: Double
    
    /// *longitude*, and also can be *x*
    var lng: Double
    
    /// 서울시청의 좌표로 초기화한다.
    init() {
        self.lat = 37.335887
        self.lng = 126.584063
    }
    
    /// `Double Type`으로 받으면 그대로 저장한다.
    init(lat: Double, lng: Double) {
        self.lat = lat
        self.lng = lng
    }
    /// `String Type`으로 받으면 `Double`로 변환해서 저장한다.
    init(lat: String, lng: String) {
        self.lat = lat.toDouble()
        self.lng = lng.toDouble()
    }
}

// MARK: - RouteInput
struct PlaceDetail {
    var place_name: String
    var category_name: String
    var road_address_name: String
    var coordinate: Coordinate
}

struct KLResponse: Codable {
    var meta: PlaceMeta
    var documents: [Place]
    
    struct PlaceMeta: Codable {
        var total_count: Int
        var pageable_count: Int
        var is_end: Bool
        var same_name: ReginInfo
        
        struct ReginInfo: Codable {
            var region: [String]
            var keyword: String
            var selected_region: String
        }
    }
    struct Place: Codable {
        var id: String
        var place_name: String
        var category_name: String
        var category_group_code: String
        var category_group_name: String
        var phone: String
        var address_name: String
        var road_address_name: String
        var x: String
        var y: String
        var place_url: String
        var distance: String
        
        func makePlaceDetail() -> PlaceDetail {
            return PlaceDetail(place_name: self.place_name,
                               category_name: self.category_name,
                               road_address_name: self.road_address_name,
                               coordinate: Coordinate(lat: self.y, lng: self.x))
        }
    }
}



