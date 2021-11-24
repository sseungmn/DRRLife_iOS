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

// SeoulOpenData Response

struct SODResponse: Codable {
    var rentBikeStatus: RentBikeStatus
    
    struct RentBikeStatus: Codable {
        var RESULT: Result
        var list_total_count: Int
        var row: [RantalStationInfo]
        
        struct Result: Codable {
            var CODE: String
            var MESSAGE: String
        }
        
        struct RantalStationInfo: Codable {
            var parkingBikeTotCnt: String
            var rackTotCnt: String
            var shared: String
            var stationId: String
            var stationLatitude: String
            var stationLongitude: String
            var stationName: String
        }
    }
}

typealias StationInfo = SODResponse.RentBikeStatus.RantalStationInfo

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
}

// MARK: - MAP, RouteInput
struct Coordinate {
    var x: String
    var y: String
    var lat: Double
    var lng: Double
    
    // 서울시청 좌표
    init() {
        self.x = "126.584063"
        self.y = "37.335887"
        self.lat = 37.335887
        self.lng = 126.584063
    }
    
    init(x: String, y: String) {
        self.x = x
        self.y = y
        self.lat = (y as NSString).doubleValue
        self.lng = (x as NSString).doubleValue
    }
    
    init(lat: Double, lng: Double) {
        self.x = String(lng)
        self.y = String(lat)
        self.lat = lat
        self.lng = lng
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
                                coordinate: Coordinate(x: self.x, y: self.y))
        }
    }
}


