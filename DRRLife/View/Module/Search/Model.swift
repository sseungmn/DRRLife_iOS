//
//  Model.swift
//  DRRLife
//
//  Created by OHSEUNGMIN on 2021/11/23.
//

import Foundation

struct Coordinate {
    var x: String
    var y: String
    
    // 서울시청 좌표
    init() {
        self.x = "126.584063"
        self.y = "37.335887"
    }
    
    init(x: String, y: String) {
        self.x = x
        self.y = y
    }
}

struct PlaceDetail {
    var place_name: String
    var category_name: String
    var road_address_name: String
    var coordinate: Coordinate
}

struct Response: Codable {
    var meta: PlaceMeta
    var documents: [Place]
}

struct PlaceMeta: Codable {
    var total_count: Int
    var pageable_count: Int
    var is_end: Bool
    var same_name: ReginInfo
}

struct ReginInfo: Codable {
    var region: [String]
    var keyword: String
    var selected_region: String
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
