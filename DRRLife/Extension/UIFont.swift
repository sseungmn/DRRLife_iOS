//
//  UIFont.swift
//  DRRLife
//
//  Created by OHSEUNGMIN on 2021/11/25.
//

import UIKit

//====> GowunBatang-Regular
//====> GowunBatang-Bold
//Welcome Bold
//====> TTWelcomeBold
//Welcome Regular
//====> TTWelcomeRegular
//NanumSquare
//====> NanumSquareR
//====> NanumSquareL
//====> NanumSquareB


extension UIFont {
    static func themeFont(ofSize fontSize: CGFloat) -> UIFont {
        return UIFont(name: "NanumSquareR", size: fontSize)!
    }
    static func boldThemeFont(ofSize fontSize: CGFloat) -> UIFont {
        return UIFont(name: "NanumSquareB", size: fontSize)!
    }
    static func extraboldThemeFont(ofSize fontSize: CGFloat) -> UIFont {
        return UIFont(name: "NanumSquareEB", size: fontSize)!
    }
    static func lightThemeFont(ofSize fontSize: CGFloat) -> UIFont {
        return UIFont(name: "NanumSquareL", size: fontSize)!
    }
}
