//
//  TMapRoute.swift
//  DRRLife
//
//  Created by 오승민 on .
//

import Foundation
import Moya
// MARK: - TMap Route Request
enum TMRequest {
    static private let key = Bundle.main.TMapRoute
    
    case foot_walking(start: Coordinate, end: Coordinate)
}

extension TMRequest: TargetType {
    var baseURL: URL {
        return URL(string: "https://apis.openapi.sk.com/tmap/routes")!
    }
    
    var path: String {
        switch self {
        case .foot_walking:
            return "/pedestrian"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .foot_walking:
            return .get
        }
    }
    
    var task: Task {
        var parameters: [String: Any] = [
            "appKey": TMRequest.key,
            "sort": "custom",
        ]
        switch self {
        case .foot_walking(let start, let end):
            parameters["startX"] = start.lng.toString
            parameters["startY"] = start.lat.toString
            parameters["endX"] = end.lng.toString
            parameters["endY"] = end.lat.toString
            parameters["startName"] = "start"
            parameters["endName"] = "end"
            return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
        }
    }
    var headers: [String : String]? {
        return nil
    }
}

// MARK: - TMap Route Response
struct TMResponse: Decodable {
    let features: [Feature]
}

// MARK: - Feature
struct Feature: Decodable {
    let geometry: Geometry
    let properties: Properties?
}

// MARK: - Geometry
struct Geometry: Decodable {
    let type: GeometryType
    let coordinates: [Coor]
}

enum Coor: Decodable {
    case double(Double)
    case doubleArray([Double])

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let x = try? container.decode([Double].self) {
            self = .doubleArray(x)
            return
        }
        if let x = try? container.decode(Double.self) {
            self = .double(x)
            return
        }
        throw DecodingError.typeMismatch(Coor.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for Coordinate"))
    }
    
    func getDoubleArray() -> [Double]? {
        switch self {
        case .double(_):
            return nil
        case .doubleArray(let array):
            return array
        }
    }
}

enum GeometryType: String, Decodable {
    case lineString = "LineString"
    case point = "Point"
}

// MARK: - Properties
struct Properties: Decodable {
    let distance: Double?
    let duration: Double?
    let pointType: PointType?
    
    private enum CodingKeys: String, CodingKey {
        case distance = "totalDistance"
        case duration = "totalTime"
        case pointType
    }
}

enum PointType: String, Decodable {
    case ep = "EP"
    case gp = "GP"
    case sp = "SP"
}

