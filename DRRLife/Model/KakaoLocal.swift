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
    
    case location(query: String, x: String, y:String)
}

extension KLRequest: TargetType {
    var baseURL: URL {
        return URL(string: "https://dapi.kakao.com/v2/local/search")!
    }
    
    var path: String {
        switch self {
        case .location:
            return "/keyword.json"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .location:
            return .get
        }
    }
    
    var task: Task {
        let page = 1
        let size = 15
        let sort = "accuracy"
        
        switch self {
        case .location(let query, let x, let y):
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
struct PlaceDetail: Codable {
    let categoryName: String
    let distance: String
    let placeName: String
    let roadAddressName: String
    let x: String
    let y: String

    enum CodingKeys: String, CodingKey {
        case categoryName = "category_name"
        case distance = "distance"
        case placeName = "place_name"
        case roadAddressName = "road_address_name"
        case x = "x"
        case y = "y"
    }
}

extension PlaceDetail {
    var coordinate: Coordinate {
        return Coordinate(lat: y, lng: x)
    }
}
