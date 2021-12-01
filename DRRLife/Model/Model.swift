//
//  Model.swift
//  DRRLife
//
//  Created by OHSEUNGMIN on 2021/11/23.
//
import Foundation
import NMapsMap
import Then

enum RouteInput {
    case origin
    case originRantalStation
    case destination
    case destinationRantalStation
}

struct ORRequest {
    static func makeRequestURL(params: ORRequest.Parameter) -> String {
        let endpoint = "https://api.openrouteservice.org/v2/directions"
        return "\(endpoint)/\(params.toString)"
    }
    
    struct Parameter {
        let api_key = Bundle.main.Openroute
        var start: Coordinate
        var end: Coordinate
        var profile: Profile
        
        enum Profile: String {
            case cycling_regular = "cycling-regular"
            case cycling_road = "cycling-road"
            case foot_walking = "foot-walking"
        }
        
        var toString: String {
            return "\(profile.rawValue)?api_key=\(api_key)&start=\(start.toString)&end=\(end.toString)"
        }
    }
}

struct SODRequestURL {
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
struct SODStationInformation {
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
    var rentBikeStatus: SODRentBikeStatus
    
    struct SODRentBikeStatus: Codable {
        var RESULT: SODResult
        var list_total_count: Int
        var row: [SODRantalStationStatus]
        
        struct SODResult: Codable {
            var CODE: String
            var MESSAGE: String
        }
        
        struct SODRantalStationStatus: Codable {
            var parkingBikeTotCnt: String
            var rackTotCnt: String
            var shared: String
            var stationId: String
            var stationLatitude: String
            var stationLongitude: String
            var stationName: String
            
            func makeStationDetail() -> StationStatus {
                var formattedStationName = self.stationName.components(separatedBy: ["."]).last!
                if formattedStationName.first == " " { formattedStationName.removeFirst() }
                return StationStatus(stationName: formattedStationName,
                                     rackTotCnt: self.rackTotCnt.toInt,
                                     parkingBikeTotCnt: self.parkingBikeTotCnt.toInt,
                                     coordinate: Coordinate(lat: self.stationLatitude, lng: self.stationLongitude))
            }
        }
    }
    
}

typealias StationInfo = SODResponse.SODRentBikeStatus.SODRantalStationStatus
// MARK: - MAP
class Marker {
    static let shared = Marker()
    
    var selectedMarker: NMFMarker? {
        didSet(oldMarker) {
            oldMarker?.height = 30
            oldMarker?.width = 30
        }
        willSet(newMarker) {
            newMarker?.height = 70
            newMarker?.width = 70
        }
    }
    
    lazy var locationMarker = NMFMarker().then {
        $0.iconImage = NMF_MARKER_IMAGE_BLACK
        $0.iconTintColor = UIColor.red
        $0.width = 30
        $0.height = 30
    }
    lazy var allCases = [oriMarker, oriRantalMarker, dstMarker, dstRantalMarker]
    var oriMarker = NMFMarker().then {
        $0.iconImage = NMF_MARKER_IMAGE_RED
        $0.captionText = "출발지".localized()
        
        $0.isHideCollidedSymbols = true
        $0.isHideCollidedCaptions = true
    }
    var oriRantalMarker = NMFMarker().then {
        $0.iconImage = NMF_MARKER_IMAGE_PINK
        $0.captionText = "출발 대여소".localized()
        
        $0.isHideCollidedSymbols = true
        $0.isHideCollidedCaptions = true
    }
    var dstMarker = NMFMarker().then {
        $0.iconImage = NMF_MARKER_IMAGE_GREEN
        $0.captionText = "도착지".localized()
        
        $0.isHideCollidedSymbols = true
        $0.isHideCollidedCaptions = true
    }
    var dstRantalMarker = NMFMarker().then {
        $0.iconImage = NMF_MARKER_IMAGE_BLUE
        $0.captionText = "도착 대여소".localized()
        
        $0.isHideCollidedSymbols = true
        $0.isHideCollidedCaptions = true
    }
    
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
    func swapRouteParams() {
        var tmpPosition = oriMarker.position
        oriMarker.position = dstMarker.position
        dstMarker.position = tmpPosition
        
        tmpPosition = oriRantalMarker.position
        oriRantalMarker.position = dstRantalMarker.position
        dstRantalMarker.position = tmpPosition
        
        var tmpMapview = oriMarker.mapView
        oriMarker.mapView = dstMarker.mapView
        dstMarker.mapView = tmpMapview
        
        tmpMapview = oriRantalMarker.mapView
        oriRantalMarker.mapView = dstRantalMarker.mapView
        dstRantalMarker.mapView = tmpMapview
    }
}

// MARK: - MAP, Search
/// Contain variables for using coordinate
struct Coordinate {
    /// *latitude*, and also can be *y*
    var lat: Double
    
    /// *longitude*, and also can be *x*
    var lng: Double
    var toString: String {
        return "\(lng),\(lat)"
    }
    
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
        self.lat = lat.toDouble
        self.lng = lng.toDouble
    }
}

// MARK: - Search
struct PlaceDetail {
    var place_name: String
    var category_name: String
    var road_address_name: String
    var coordinate: Coordinate
    
    init(place_name: String, category_name: String, road_address_name: String, coordinate: Coordinate) {
        self.place_name = place_name
        self.category_name = category_name
        self.road_address_name = road_address_name
        self.coordinate = coordinate
    }
    
    init() {
        self.place_name = ""
        self.category_name = ""
        self.road_address_name = ""
        self.coordinate = Coordinate()
    }
}

struct KLResponse: Codable {
    var meta: KLPlaceMeta
    var documents: [KLPlace]
    
    struct KLPlaceMeta: Codable {
        var total_count: Int
        var pageable_count: Int
        var is_end: Bool
        var same_name: KLReginInfo
        
        struct KLReginInfo: Codable {
            var region: [String]
            var keyword: String
            var selected_region: String
        }
    }
    struct KLPlace: Codable {
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

// MARK: - RouteInput
class RouteParams {
    var origin: PlaceDetail?
    var originStation: StationStatus?
    var destination: PlaceDetail?
    var destinationStation: StationStatus?
    
    var allCases: [Any?] {
       return [origin, originStation, destination, destinationStation]
    }
    
    var didCompleteFilling: Bool {
        return (
            origin != nil &&
            originStation != nil &&
            destination != nil &&
            destinationStation != nil
        )
    }
    
    func swap() {
        Swift.swap(&origin, &destination)
        Swift.swap(&originStation, &destinationStation)
    }
}
