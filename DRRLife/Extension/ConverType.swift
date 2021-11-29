//
//  ConverType.swift
//  DRRLife
//
//  Created by 오승민 on .
//

import Foundation
import NMapsMap

extension String {
    var toInt: Int {
        return (self as NSString).integerValue
    }
    var toDouble: Double {
        return (self as NSString).doubleValue
    }
}

extension Double {
    var toString: String {
        return String(self)
    }
}

extension Int {
    var toString: String {
        return String(self)
    }
}

extension Array where Element == [Double]  {
    func toNMGLatLngArray() -> [NMGLatLng] {
        return self.map { coor in
            return NMGLatLng(lat: coor.last!, lng: coor.first!)
        }
    }
}
