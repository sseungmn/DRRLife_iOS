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
    
    var selectedMarker: BaseMarker? {
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

struct MarkerImageManager {
    static let shared = MarkerImageManager()
    
    private let grayImage = NMFOverlayImage(name: "gray")
    private let orangerImage = NMFOverlayImage(name: "orange")
    private let redImage = NMFOverlayImage(name: "red")
    private let greenImage = NMFOverlayImage(name: "green")
    private let originImage = NMFOverlayImage(name: "origin")
    private let originStationImage = NMFOverlayImage(name: "originStationImage ")
    private let destinationStationImage = NMFOverlayImage(name: "destinationStationImage")
    private let destinationImage = NMFOverlayImage(name: "destination")
    
    func getImage(type: ImageType) -> NMFOverlayImage {
        switch type {
        case .gray:
            return grayImage
        case .red:
            return redImage
        case .orange:
            return orangerImage
        case .green:
            return greenImage
        case .origin:
            return originImage
        case .originStation:
            return originStationImage
        case .destinationStation:
            return destinationStationImage
        case .destination:
            return destinationImage
        }
    }
    enum ImageType {
        case gray
        case red
        case orange
        case green
        case origin
        case originStation
        case destinationStation
        case destination
    }
}
// MARK: Base
class BaseMarker: NMFMarker {
    override init() {
        super.init()
        isHideCollidedSymbols = false
        isHideCollidedCaptions = false
        isForceShowIcon = false
    }
    
    
}

// MARK: StationMarker
class StationMarker: BaseMarker {
    override init() {
        super.init()
        self.width = 40
        self.height = 40
        self.zIndex = 0 // Marker중 가장 아래 존재
        self.isForceShowIcon = false
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
            MarkerManager.shared.selectedMarker = overlay as? BaseMarker
            return true
        }
        
        self.captionText = station.stationName
        self.iconImage = calcMarkerIcon(by: station.parkingBikeTotCnt)
        self.minZoom = calcMinZoomLevel(by: station.parkingBikeTotCnt)
        
        self.mapView = mapVC.mapView
    }
    
    private func calcMarkerIcon(by parkingBikeTotCnt: Int) -> NMFOverlayImage {
        if parkingBikeTotCnt == 0 {
            return MarkerImageManager.shared.getImage(type: .gray)
        } else if parkingBikeTotCnt <= 5 {
            return MarkerImageManager.shared.getImage(type: .red)
        } else if parkingBikeTotCnt <= 10 {
            return MarkerImageManager.shared.getImage(type: .orange)
        } else {
            return MarkerImageManager.shared.getImage(type: .green)
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
class ParamMarker: BaseMarker {
    var type: RouteInputType
    
    init(type: RouteInputType) {
        self.type = type
        
        super.init()
        
        self.setMetaByType()
        self.width = 60
        self.height = 60
        self.isForceShowIcon = true // 겹쳐도 무조건 표시
        isHideCollidedSymbols = true
        isHideCollidedCaptions = true
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
            self.iconImage = MarkerImageManager.shared.getImage(type: .origin)
            self.captionText = "출발지".localized()
            self.zIndex = 2 // Marker중 가장 높은곳에 존재
        case .originRantalStation:
            self.iconImage = MarkerImageManager.shared.getImage(type: .originStation)
            self.captionText = "출발 대여소".localized()
            self.zIndex = 1 
        case .destinationRantalStation:
            self.iconImage = MarkerImageManager.shared.getImage(type: .destinationStation)
            self.captionText = "도착 대여소".localized()
            self.zIndex = 1
        case .destination:
            self.iconImage = MarkerImageManager.shared.getImage(type: .destination)
            self.captionText = "도착지".localized()
            self.zIndex = 2 // Marker중 가장 높은곳에 존재
        }
    }
}
