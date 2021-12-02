//
//  Marker.swift
//  DRRLife
//
//  Created by 오승민 on .
//

import Foundation
import NMapsMap

// MARK: MarkerManager
struct MarkerManager {
    static var shared = MarkerManager()
    
    var selectedMarker: MarkerBase? {
        didSet(oldMarker) {
            oldMarker?.height = 40
            oldMarker?.width = 40
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
    
    lazy var allCases = [originMarker, originRantalMarker,
                         destinationMarker, destinationRantalMarker]
    var originMarker =  ParamMarker(type: .origin)
    var originRantalMarker = ParamMarker(type: .originRantalStation)
    var destinationMarker = ParamMarker(type: .destination)
    var destinationRantalMarker = ParamMarker(type: .destinationRantalStation)
    func getParamMarker(type: RouteInputType) -> ParamMarker {
        switch type {
        case .origin:
            return originMarker
        case .originRantalStation:
            return originRantalMarker
        case .destination:
            return destinationMarker
        case .destinationRantalStation:
            return destinationRantalMarker
        }
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
        var tmpPosition = originMarker.position
        originMarker.position = destinationMarker.position
        destinationMarker.position = tmpPosition
        
        tmpPosition = originRantalMarker.position
        destinationRantalMarker.position = destinationRantalMarker.position
        destinationRantalMarker.position = tmpPosition
        
        var tmpMapview = originMarker.mapView
        originMarker.mapView = destinationMarker.mapView
        destinationMarker.mapView = tmpMapview
        
        tmpMapview = originRantalMarker.mapView
        originRantalMarker.mapView = destinationRantalMarker.mapView
        destinationRantalMarker.mapView = tmpMapview
    }
}

// MARK: Base
class MarkerBase: NMFMarker {
    override init() {
        super.init()
        isHideCollidedSymbols = true
        isHideCollidedCaptions = true
    }
}

// MARK: StationMarker
class StationMarker: MarkerBase {
    override init() {
        super.init()
        self.width = 40
        self.height = 40
        self.zIndex = 0 // Marker중 가장 아래 존재
    }
    convenience init(station: StationStatus, mapVC: MapViewController) {
        self.init()
        
        let userInfo: [AnyHashable : Any] = ["mapVC" : mapVC,
                                             "stationStatus" : station]
        
        self.position = NMGLatLng(from: station.coordinate.toCLLocationCoordinate2D)
        self.userInfo = userInfo
        self.touchHandler = { (overlay: NMFOverlay) -> Bool in
            guard let mapVC = userInfo["mapVC"] as? MapViewController else {
                print("해당 MapView가 존재하지 않습니다.")
                return true
            }
            guard let stationStatus = userInfo["stationStatus"] as? StationStatus else {
                print("해당 stationStatus가 존재하지 않습니다.")
                return true
            }
            print("\(stationStatus.stationName)에서 touchEvent 발생")
            mapVC.setCamera(to: stationStatus.coordinate)
            mapVC.showLocationInfo(stationStatus: stationStatus)
            MarkerManager.shared.selectedMarker = overlay as? MarkerBase
            return true
        }
        
        self.captionText = station.stationName
        self.iconImage = calcMarkerIcon(by: station.parkingBikeTotCnt)
        self.minZoom = calcMinZoomLevel(by: station.parkingBikeTotCnt)
        
        self.mapView = mapVC.mapView
    }
    
    private func calcMarkerIcon(by parkingBikeTotCnt: Int) -> NMFOverlayImage {
        if parkingBikeTotCnt == 0 {
            return NMFOverlayImage(name: "grayMarker")
        } else if parkingBikeTotCnt <= 5 {
            return NMFOverlayImage(name: "redMarker")
        } else if parkingBikeTotCnt <= 10 {
            return NMFOverlayImage(name: "orangeMarker")
        } else {
            return NMFOverlayImage(name: "greenMarker")
        }
    }
    
    private func calcMinZoomLevel(by rackTotCnt: Int) -> Double {
        if rackTotCnt < 10 {
            return NMF_MIN_ZOOM + 14
        } else if rackTotCnt < 15 {
            return NMF_MIN_ZOOM + 12
        } else if rackTotCnt < 20 {
            return NMF_MIN_ZOOM + 10
        } else if rackTotCnt < 30 {
            return NMF_MIN_ZOOM + 8
        } else {
            return NMF_MIN_ZOOM + 6
        }
    }
}

// MARK: ParamMarker
class ParamMarker: MarkerBase {
    var type: RouteInputType
    
    init(type: RouteInputType) {
        self.type = type
        
        super.init()
        
        self.setMetaByType()
        self.width = 50
        self.height = 50
        self.zIndex = 1 // Marker중 가장 높은곳에 존재
    }
    
    func register() {
        switch type {
        case .origin:
            MarkerManager.shared.originMarker = self
        case .originRantalStation:
            MarkerManager.shared.originRantalMarker = self
        case .destination:
            MarkerManager.shared.destinationMarker = self
        case .destinationRantalStation:
            MarkerManager.shared.destinationRantalMarker = self
        }
    }
    
    private func setMetaByType() {
        switch type {
        case .origin:
            self.iconImage = NMF_MARKER_IMAGE_RED
            self.captionText = "출발지".localized()
        case .originRantalStation:
            self.iconImage = NMF_MARKER_IMAGE_PINK
            self.captionText = "출발 대여소".localized()
        case .destinationRantalStation:
            self.iconImage = NMF_MARKER_IMAGE_GREEN
            self.captionText = "도착 대여소".localized()
        case .destination:
            self.iconImage = NMF_MARKER_IMAGE_BLUE
            self.captionText = "도착지".localized()
        }
    }
}
