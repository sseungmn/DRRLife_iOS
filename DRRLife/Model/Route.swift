//
//  Route.swift
//  DRRLife
//
//  Created by 오승민 on .
//

import Foundation
import NMapsMap

enum RouteType {
    case cycling_regular
    case cycling_road
    case cycling_electric
    case foot_walking_start
    case foot_walking_end
}

class RouteManager {
    static let shared = RouteManager()
    static var mapView: NMFMapView? = nil
    static var count = 0
    
    lazy var cycling_regular = Route(mapView: RouteManager.mapView!, type: .cycling_regular).then {
        $0.color = .systemGreen
        $0.width = 4
    }
    lazy var cycling_road = Route(mapView: RouteManager.mapView!, type: .cycling_road).then {
        $0.color = .systemGreen
        $0.width = 4
    }
    lazy var cycling_electric = Route(mapView: RouteManager.mapView!, type: .cycling_electric).then {
        $0.color = .systemGreen
        $0.width = 4
    }
    lazy var foot_walking_start = Route(mapView: RouteManager.mapView!, type: .foot_walking_start).then {
        $0.color = .systemYellow
        $0.width = 8
    }
    lazy var foot_walking_end = Route(mapView: RouteManager.mapView!, type: .foot_walking_end).then {
        $0.color = .systemYellow
        $0.width = 8
    }
    lazy var recommendCyclingRoute = getRecommendCyclingRoute()
    
    func getRecommendCyclingRoute() -> Route {
        return [cycling_regular, cycling_road, cycling_electric].min { firstRoute, secondRoute in
            firstRoute.duration! < secondRoute.duration!
        } as! Route
    }
    
    func hideAllRoute() {
        [recommendCyclingRoute, foot_walking_start, foot_walking_end].forEach({
            $0.hideRoute()
        })
    }
}

class Route: NMFPath {
    private var type: RouteType
    private var _mapView: NMFMapView
    
    var duration: Double?
    var distance: Double?
    
    init(mapView: NMFMapView, type: RouteType) {
        self._mapView = mapView
        self.type = type
        
        super.init()
    }
    
    func showRoute() {
        self.mapView = _mapView
    }
    
    func hideRoute() {
        self.mapView = nil
    }
}
