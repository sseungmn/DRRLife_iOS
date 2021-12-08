//
//  SeoulOpenData.swift.swift
//  DRRLife
//
//  Created by 오승민 on .
//

import Foundation
import Moya

enum SODRequest {
    static private let key = Bundle.main.SeoulOpenData
    
    case station(start: Int, end: Int)
}

extension SODRequest: TargetType {
    var baseURL: URL {
        return URL(string: "http://openapi.seoul.go.kr:8088")!
    }
    
    var path: String {
        switch self {
        case .station(let start, let end):
            return "/\(SODRequest.key)/json/bikeList/\(start)/\(end)"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .station:
            return .get
        }
    }
    
    var task: Task {
        switch self {
        case .station:
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        return nil
    }
}

// MARK: - Seoul Open Data Response
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
