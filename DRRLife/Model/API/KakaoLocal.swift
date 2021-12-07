//
//  APIModel.swift
//  DRRLife
//
//  Created by 오승민 on .
//

import Moya
import UIKit

// MARK: Kakao Local Request
enum KLRequest {
    static private let key = Bundle.main.KakaoLocal
    
    case local(query: String, x: String, y:String)
}

extension KLRequest: TargetType {
    var baseURL: URL {
        return URL(string: "https://dapi.kakao.com/v2/local/search")!
    }
    
    var path: String {
        switch self {
        case .local:
            return "/keyword.json"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .local:
            return .get
        }
    }
    
    var task: Task {
        let page = 1
        let size = 15
        let sort = "accuracy"
        
        switch self {
        case .local(let query, let x, let y):
            return .requestParameters(
                parameters: [
                    "query": query,
                    "x": x,
                    "y": y,
                    "page": page,
                    "size": size,
                    "sort": sort
                ], encoding: URLEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        return ["Authorization": "KakaoAK \(KLRequest.key)"]
    }
    
}

// MARK: - Kakao Local Response
struct KLResponse: Codable {
    let documents: [PlaceDetail]

    enum CodingKeys: String, CodingKey {
        case documents = "documents"
    }
}

// MARK: - PlaceDetail
struct PlaceDetail: Codable, Location {
    let categoryName: String
    let distance: String
    let latitude: String
    let longitude: String
    
    var name: String
    var address: String?
    var coordinate: Coordinate {
        return Coordinate(lat: latitude, lng: longitude)
    }

    private enum CodingKeys: String, CodingKey {
        case categoryName = "category_name"
        case distance = "distance"
        case name = "place_name"
        case address = "road_address_name"
        case longitude = "x"
        case latitude = "y"
    }
}
