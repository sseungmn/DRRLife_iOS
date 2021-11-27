//
//  ConverType.swift
//  DRRLife
//
//  Created by 오승민 on .
//

import Foundation

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
