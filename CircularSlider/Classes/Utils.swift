//
//  Utils.swift
//  CircularSliderExample
//
//  Created by Matteo Tagliafico on 02/09/16.
//  Copyright © 2016 Matteo Tagliafico. All rights reserved.
//

import Foundation
import UIKit


extension Float {
    
    func format(_ f: String) -> String {
        return String(format: "%\(f)f", self)
    }
    
    func formatForCurrency() -> String {
        
        let fmt = NumberFormatter()
        fmt.numberStyle = .decimal
        fmt.decimalSeparator = ","
        fmt.maximumFractionDigits = 2
        fmt.minimumFractionDigits = 2
        
        guard let numberString = fmt.string(from: NSNumber(value: self)) else { return "" }
        
        let decimalString = numberString.substring(from: (numberString.characters.index(numberString.endIndex, offsetBy: -3)))
        let integerString = numberString.substring(to: (numberString.characters.index(numberString.endIndex, offsetBy: -3)))
        let outputNumber = integerString.replacingOccurrences(of: ",", with: ".")
        
        return outputNumber + decimalString
    }
}


extension String {
    
    func toFloat(_ localeIdentifier: String? = "it_IT") -> Float {
        let locale = localeIdentifier == nil ? Locale.current : Locale(identifier: localeIdentifier!)
        let cf = NumberFormatter()
        cf.locale = locale
        cf.numberStyle = .decimal
        cf.maximumFractionDigits = 2
        cf.roundingMode = .down
        let t = self.replacingOccurrences(of: ",", with: cf.decimalSeparator)
        return cf.number(from: t)?.floatValue ?? 0
    }
    
    func sliderAttributeString(intFont: UIFont, decimalFont: UIFont) -> NSAttributedString {
        guard self != "" else { return NSAttributedString(string: "") }
        
        let currencyAttributeString = NSMutableAttributedString()
        let interaString = substring(with: startIndex..<characters.index(startIndex, offsetBy: characters.count - 2))
        let decimaleString = substring(with: characters.index(startIndex, offsetBy: characters.count - 2)..<characters.index(startIndex, offsetBy: characters.count - 0)) + " "
        
        let intera = NSMutableAttributedString(string: interaString)
        let decimale = NSMutableAttributedString(string: decimaleString)
        
        // add attributes
        if #available(iOS 8.2, *) {
            intera.addAttributes([NSFontAttributeName: UIFont.systemFont(ofSize: 42, weight: UIFontWeightRegular)], range: NSMakeRange(0, intera.length))
            decimale.addAttributes([NSFontAttributeName: UIFont.systemFont(ofSize: 42, weight: UIFontWeightThin)], range: NSMakeRange(0, decimale.length))
        } else {
            intera.addAttributes([NSFontAttributeName: UIFont.systemFont(ofSize: 42)], range: NSMakeRange(0, intera.length))
            decimale.addAttributes([NSFontAttributeName: UIFont.systemFont(ofSize: 42)], range: NSMakeRange(0, decimale.length))
        }
        
        
        currencyAttributeString.append(intera)
        currencyAttributeString.append(decimale)
        
        return currencyAttributeString
    }
}
