//
//  RotationGesture.swift
//  CircularSliderExample
//
//  Created by Matteo Tagliafico on 04/09/16.
//  Copyright © 2016 Matteo Tagliafico. All rights reserved.
//

import UIKit.UIGestureRecognizerSubclass

open class RotationGestureRecognizer: UIPanGestureRecognizer {
    
    // MARK: - properties
    var arcRadius: CGFloat = 100
    fileprivate var valid = false
    fileprivate var knobRadius: CGFloat = 10
    
    open var rotation: CGFloat = 0
    open var tollerance: CGFloat = 0.5
    
    
    // MARK: - init
    init(target: AnyObject?, action: Selector, arcRadius: CGFloat, knobRadius: CGFloat) {
        self.arcRadius = arcRadius
        self.knobRadius = knobRadius
        super.init(target: target, action: action)
        configure()
    }
    
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        
        if isInsideRing(touches) {
            valid = true
            updateRotationWithTouches(touches)
        } else {
            valid = false
            cancel()
        }
    }
    
    override open func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesMoved(touches, with: event)
        guard valid == true else {
            cancel()
            return
        }
        updateRotationWithTouches(touches)
    }
    
    func updateRotationWithTouches(_ touches: Set<NSObject>) {
        if let touch = touches[touches.startIndex] as? UITouch {
            print(rotation)
            rotation = rotationForLocation(touch.location(in: view))
        }
    }
    
    
    // MARK: - methods
    fileprivate func configure() {
        minimumNumberOfTouches = 1
        maximumNumberOfTouches = 1
        cancelsTouchesInView = false
    }
    
    fileprivate func isInsideRing(_ touches: Set<NSObject>) -> Bool{
        guard let touch = touches[touches.startIndex] as? UITouch else { return false }
        let location = touch.location(in: view)
        
        let outerRadius = arcRadius + knobRadius * (1 + tollerance)
        let innerRadius = arcRadius - knobRadius * (1 + tollerance)
        
        let dist = sqrt(pow(location.x - view!.bounds.midX, 2) + pow(location.y - view!.bounds.midY, 2))
        
        return dist <= outerRadius && dist >= innerRadius
    }
    
    fileprivate func rotationForLocation(_ location: CGPoint) -> CGFloat {
        let offset = CGPoint(x: location.x - view!.bounds.midX, y: location.y - view!.bounds.midY)
        return atan2(offset.y, offset.x)
    }
    
    func cancel() {
        isEnabled = false
        isEnabled = true
    }
}
