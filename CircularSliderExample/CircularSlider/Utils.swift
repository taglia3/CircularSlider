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
    
    func format(f: String) -> String {
        return String(format: "%\(f)f", self)
    }
    
    func formatForCurrency() -> String {
        
        let fmt = NumberFormatter()
        
        fmt.numberStyle = .decimal
        fmt.decimalSeparator = ","
        fmt.maximumFractionDigits = 2
        fmt.minimumFractionDigits = 2
        
        let numberString = fmt.string(from: NSNumber(value: self))
        let splitedString = numberString?.split(separator: ",")
        
        return "\(splitedString?.first ?? "0").\(splitedString?.last ?? "0")"
    }
}


extension String {
    
    func toFloat(localeIdentifier: String? = "it_IT") -> Float {
        let locale = localeIdentifier == nil ? NSLocale.current : NSLocale(localeIdentifier: localeIdentifier!) as Locale
        let cf = NumberFormatter()
        cf.locale = locale
        cf.numberStyle = .decimal
        cf.maximumFractionDigits = 2
        cf.roundingMode = .down
        let t = self.replacingOccurrences(of: ",", with: cf.decimalSeparator)
        return cf.number(from: t)?.floatValue ?? 0
    }
    
    func trim() -> String {
        return self.trimmStringwhitespaceCharacterSet()
    }
    
    func trimmStringwhitespaceCharacterSet() -> String {
        let trimmedString =
            self.trimmStringwhitespaceCharacterSet()
        return trimmedString
    }
    
    func sliderAttributeString(intFont: UIFont, decimalFont: UIFont) -> NSAttributedString {
        guard self != "" else { return NSAttributedString(string: "") }
        
        let currencyAttributeString = NSMutableAttributedString()
        
        let splitedString = "\(self)".split(separator: ".")
  
        let interaString = splitedString.first
        let decimaleString = splitedString.last
        
        let intera = NSMutableAttributedString(string: "\(interaString ?? "0").")
        let decimale = NSMutableAttributedString(string: "\(decimaleString ?? "0")")
        
        // add attributes
        if #available(iOS 8.2, *) {
            intera.addAttributes([NSAttributedStringKey.font: UIFont.systemFont(ofSize: 42, weight: UIFont.Weight.regular)], range: NSMakeRange(0, intera.length))
            decimale.addAttributes([NSAttributedStringKey.font: UIFont.systemFont(ofSize: 42, weight: UIFont.Weight.thin)], range: NSMakeRange(0, decimale.length))
        } else { }
        
        currencyAttributeString.append(intera)
        currencyAttributeString.append(decimale)
        
        return currencyAttributeString
    }
}


