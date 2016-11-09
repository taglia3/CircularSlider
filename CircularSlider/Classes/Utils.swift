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
    
    func formatWithFractionDigits(_ fractionDigits: Int, customDecimalSeparator: String? = nil) -> String {
        
        let fmt = NumberFormatter()
        fmt.numberStyle = .decimal
        fmt.maximumFractionDigits = fractionDigits
        fmt.minimumFractionDigits = fractionDigits
        fmt.decimalSeparator = customDecimalSeparator ?? fmt.decimalSeparator
        
        return  fmt.string(from: NSNumber(value: self)) ?? ""
    }
}


extension String {
    
    func toFloat(_ localeIdentifier: String? = nil) -> Float {
        let locale = localeIdentifier != nil ?  Locale(identifier: localeIdentifier!) : Locale.current
        
        let fmt = NumberFormatter()
        fmt.locale = locale
        fmt.numberStyle = .decimal
        fmt.maximumFractionDigits = 2
        fmt.roundingMode = .down
        
        return fmt.number(from: self)?.floatValue ?? 0
    }
    
    func sliderAttributeString(intFont: UIFont, decimalFont: UIFont, customDecimalSeparator: String? = nil) -> NSAttributedString {
        guard self != "" else { return NSAttributedString(string: "") }
        
        let locale = Locale.current
        let fmt = NumberFormatter()
        fmt.locale = locale
        fmt.decimalSeparator = customDecimalSeparator ?? fmt.decimalSeparator
        
        let numberComponents = components(separatedBy: fmt.decimalSeparator)
        
        let attributeString = NSMutableAttributedString()
        var integerStr = numberComponents[0]
        
        var decimalStr = ""
        if numberComponents.count > 1 {
            integerStr += fmt.decimalSeparator
            decimalStr =  numberComponents[1]
        }
        
        let integer = NSMutableAttributedString(string: integerStr)
        let decimal = NSMutableAttributedString(string: decimalStr)
        
        // add attributes
        if #available(iOS 8.2, *) {
            integer.addAttributes([NSFontAttributeName: UIFont.systemFont(ofSize: 42, weight: UIFontWeightRegular)], range: NSMakeRange(0, integer.length))
            decimal.addAttributes([NSFontAttributeName: UIFont.systemFont(ofSize: 42, weight: UIFontWeightThin)], range: NSMakeRange(0, decimal.length))
        } else {
            integer.addAttributes([NSFontAttributeName: UIFont.systemFont(ofSize: 42)], range: NSMakeRange(0, integer.length))
            decimal.addAttributes([NSFontAttributeName: UIFont.systemFont(ofSize: 42)], range: NSMakeRange(0, decimal.length))
        }
        
        
        attributeString.append(integer)
        attributeString.append(decimal)
        
        return attributeString
    }
}
