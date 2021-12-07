//
//  Model.swift
//  DRRLife
//
//  Created by OHSEUNGMIN on 2021/11/23.
//
import Foundation
import NMapsMap
import Then

protocol Location {
    var name: String { get set }
    var address: String? { get set }
    var coordinate: Coordinate { get }
}

enum RouteInputType {
    case origin
    case originRantalStation
    case destination
    case destinationRantalStation
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
//struct StationStatus {
//    var stationName: String
//    var parkingBikeTotCnt: Int
//    var coordinate: Coordinate
//}

struct SODResponse: Decodable {
    var rentBikeStatus: SODRentBikeStatus
}
    
struct SODRentBikeStatus: Decodable {
    var row: [StationStatus]
}
    
struct StationStatus: Decodable, Location {
    var parkingBikeTotCnt: String
    var latitude: String
    var longitude: String
    
    var name: String
    var address: String?
    var coordinate: Coordinate {
        return Coordinate(lat: latitude, lng: longitude)
    }
//    var stationId: String
    
    private enum CodingKeys: String, CodingKey {
        case parkingBikeTotCnt
        case latitude = "stationLatitude"
        case longitude = "stationLongitude"
        case name = "stationName"
    }
}

/// Contain variables for using coordinate
///
/// - lat : *latitude* and also can be *y*
/// - lng : *longitude*, and also can be *x*
struct Coordinate: Decodable {
    /// *latitude*, and also can be *y*
    var lat: Double
    /// *longitude*, and also can be *x*
    var lng: Double
    var toString: String {
        return "\(lng),\(lat)"
    }
    var toCLLocationCoordinate2D: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: lat, longitude: lng)
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
