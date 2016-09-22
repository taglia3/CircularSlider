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
        
        let fmt = NSNumberFormatter()
        
        fmt.numberStyle = .DecimalStyle
        fmt.decimalSeparator = ","
        fmt.maximumFractionDigits = 2
        fmt.minimumFractionDigits = 2
        
        let numberString = fmt.stringFromNumber(self)
        
        let decimalString = numberString?.substringFromIndex((numberString?.endIndex.advancedBy(-3))!)
        let integerString = numberString?.substringToIndex((numberString?.endIndex.advancedBy(-3))!)
        
        let outputNumber = integerString?.stringByReplacingOccurrencesOfString(",", withString: ".")
        
        return outputNumber! + decimalString!
    }
}


extension String {
    
    func toFloat(localeIdentifier: String? = "it_IT") -> Float {
        let locale = localeIdentifier == nil ? NSLocale.currentLocale() : NSLocale(localeIdentifier: localeIdentifier!)
        let cf = NSNumberFormatter()
        cf.locale = locale
        cf.numberStyle = .DecimalStyle
        cf.maximumFractionDigits = 2
        cf.roundingMode = .RoundDown
        let t = self.stringByReplacingOccurrencesOfString(",", withString: cf.decimalSeparator)
        return cf.numberFromString(t)?.floatValue ?? 0
    }
    
    func trim() -> String {
        return self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
    }
    
    func trimmStringwhitespaceCharacterSet() -> String {
        let trimmedString = self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        
        return trimmedString
    }
    
    func sliderAttributeString(intFont intFont: UIFont, decimalFont: UIFont) -> NSAttributedString {
        guard self != "" else { return NSAttributedString(string: "") }
        
        let currencyAttributeString = NSMutableAttributedString()
        let interaString = substringWithRange(startIndex..<startIndex.advancedBy(characters.count - 2))
        let decimaleString = substringWithRange(startIndex.advancedBy(characters.count - 2)..<startIndex.advancedBy(characters.count - 0)) + " "
        
        let intera = NSMutableAttributedString(string: interaString)
        let decimale = NSMutableAttributedString(string: decimaleString)
        
        // add attributes
        intera.addAttributes([NSFontAttributeName: UIFont.systemFontOfSize(42, weight: UIFontWeightRegular)], range: NSMakeRange(0, intera.length))
        decimale.addAttributes([NSFontAttributeName: UIFont.systemFontOfSize(42, weight: UIFontWeightThin)], range: NSMakeRange(0, decimale.length))
        
        currencyAttributeString.appendAttributedString(intera)
        currencyAttributeString.appendAttributedString(decimale)
        
        return currencyAttributeString
    }
}