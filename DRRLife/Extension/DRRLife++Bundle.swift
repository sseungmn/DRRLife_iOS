//
//  DRRLife++Bundle.swift
//  DRRLife
//
//  Created by OHSEUNGMIN on 2021/11/20.
//

import Foundation

extension Bundle {
    var NMFClientId: String {
        return getKey(of: "NFMClientId")
    }
    var NaverMap: String {
        return getKey(of: "NaverMap")
    }
    var KakaoLocal: String {
        return getKey(of: "KakaoLocal")
    }
    var Openroute: String {
        return getKey(of: "Openroute")
    }
    var SeoulOpenData: String {
        return getKey(of: "SeoulOpenData")
    }
    
    private func getKey(of name: String)-> String {
        guard let file = path(forResource: "APIKeys", ofType: "plist") else { fatalError("APIKeys.plist 파일이 존재하지 않습니다.") }
        guard let resource = NSDictionary(contentsOfFile: file) else { fatalError("APIKeys.plist 파일의 형식이 알맞지 않습니다.") }
        guard let key = resource[name] as? String else { fatalError("해당 API Key가 존재하지 않습니다.")}
        return key
    }
}
