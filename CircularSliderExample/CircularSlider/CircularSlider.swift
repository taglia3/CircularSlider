//
//  CircularSlider.swift
//  CircularSliderExample
//
//  Created by Matteo Tagliafico on 02/09/16.
//  Copyright © 2016 Matteo Tagliafico. All rights reserved.
//

import Foundation
import UIKit

public enum CircularSliderType: Int {
    case normal = 0, timer
}

@objc public protocol CircularSliderDelegate: NSObjectProtocol {
    optional func circularSlider(circularSlider: CircularSlider, valueForValue value: Float) -> Float
//    optional func circularSlider(circularSlider: CircularSlider, attributeTextForValue value: Float) -> NSAttributedString
    optional func circularSlider(circularSlider: CircularSlider, didBeginEditing textfield: UITextField)
    optional func circularSlider(circularSlider: CircularSlider, didEndEditing textfield: UITextField)
}


@IBDesignable
public class CircularSlider: UIView {
    
    // MARK: - outlets
    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var iconCenterY: NSLayoutConstraint!
    @IBOutlet private weak var timeCenterY: NSLayoutConstraint!
    @IBOutlet private weak var normalView: UIView!
    @IBOutlet private weak var codeView: UIView!
    @IBOutlet private weak var timeLabel: UILabel!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var textfield: UITextField!
    @IBOutlet private weak var divisaLabel: UILabel!
    
    
    // MARK: - properties
    public weak var delegate: CircularSliderDelegate?
    
    private var containerView: UIView!
    private var nibName = "CircularSlider"
    private var backgroundCircleLayer = CAShapeLayer()
    private var progressCircleLayer = CAShapeLayer()
    private var knobLayer = CAShapeLayer()
    private var backingValue: Float = 0
    private var backingKnobAngle: CGFloat = 0
    private var backingtype: CircularSliderType = .normal
    private var startAngle: CGFloat {
        return -CGFloat(M_PI_2) + radiansOffset
    }
    private var endAngle: CGFloat {
        return 3 * CGFloat(M_PI_2) - radiansOffset
    }
    private var angleRange: CGFloat {
        return endAngle - startAngle
    }
    private var valueRange: Float {
        return maximumValue - minimumValue
    }
    private var arcCenter: CGPoint {
        return CGPointMake(CGRectGetWidth(frame) / 2, CGRectGetHeight(frame) / 2)
    }
    private var arcRadius: CGFloat {
        return min(CGRectGetWidth(frame),CGRectGetHeight(frame)) / 2 - lineWidth / 2
    }
    private var normalizedValue: Float {
        return (value - minimumValue) / (maximumValue - minimumValue)
    }
    private var knobAngle: CGFloat {
        return CGFloat(normalizedValue) * angleRange + startAngle
    }
    private var knobMidAngle: CGFloat {
        return (2 * CGFloat(M_PI) + startAngle - endAngle) / 2 + endAngle
    }
    private var knobRotationTransform: CATransform3D {
        return CATransform3DMakeRotation(knobAngle, 0.0, 0.0, 1)
    }
    private var numberOfDecimalDigits = 2 {
        didSet {
            appearanceValue()
        }
    }
    private var intFont = UIFont.systemFontOfSize(42, weight: UIFontWeightRegular) {
        didSet {
            appearanceValue()
        }
    }
    private var decimalFont = UIFont.systemFontOfSize(42, weight: UIFontWeightThin) {
        didSet {
            appearanceValue()
        }
    }
    private var divisaFont = UIFont.systemFontOfSize(26, weight: UIFontWeightThin) {
        didSet {
            appearanceDivisa()
        }
    }
    
    @IBInspectable
    public var title: String = "Title" {
        didSet {
            titleLabel.text = title
        }
    }
    @IBInspectable
    public var radiansOffset: CGFloat = 0 {
        didSet {
            setNeedsDisplay()
        }
    }
    @IBInspectable
    public var icon: UIImage? = UIImage() {
        didSet {
            configureIcon()
        }
    }
    @IBInspectable
    public var divisa: String = "" {
        didSet {
            appearanceDivisa()
        }
    }
    @IBInspectable
    public var value: Float {
        get {
            return backingValue
        }
        set {
            backingValue = min(maximumValue, max(minimumValue, newValue))
        }
    }
    @IBInspectable
    public var type: Int {
        get {
            return self.backingtype.rawValue
        }
        set(typeIndex) {
            self.backingtype = CircularSliderType(rawValue: typeIndex) ?? .normal
            configureType()
        }
    }
    @IBInspectable
    public var minimumValue: Float = 0
    @IBInspectable
    public var maximumValue: Float = 500
    @IBInspectable
    public var lineWidth: CGFloat = 5 {
        didSet {
            appearanceBackgroundLayer()
            appearanceProgressLayer()
        }
    }
    @IBInspectable
    public var bgColor: UIColor = UIColor.lightGrayColor() {
        didSet {
            appearanceBackgroundLayer()
        }
    }
    @IBInspectable
    public var pgNormalColor: UIColor = UIColor.darkGrayColor() {
        didSet {
            appearanceProgressLayer()
        }
    }
    @IBInspectable
    public var pgHighlightedColor: UIColor = UIColor.greenColor() {
        didSet {
            appearanceProgressLayer()
        }
    }
    @IBInspectable
    public var knobRadius: CGFloat = 20 {
        didSet {
            appearanceKnobLayer()
        }
    }
    @IBInspectable
    public var highlighted: Bool = true {
        didSet {
            appearanceProgressLayer()
            appearanceKnobLayer()
        }
    }
    
    
    // MARK: - init
    public override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
        configure()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
        configure()
    }
    
    private func xibSetup() {
        containerView = loadViewFromNib()
        containerView.frame = bounds
        containerView.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
        addSubview(containerView)
    }
    
    private func loadViewFromNib() -> UIView {
        let bundle = NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName: nibName, bundle: bundle)
        let view = nib.instantiateWithOwner(self, options: nil).first as! UIView
        return view
    }
    
    
    // MARK: - drawing methods
    override public func drawRect(rect: CGRect) {
        print("drawRect")
        backgroundCircleLayer.path = getCirclePath()
        progressCircleLayer.path = getCirclePath()
        knobLayer.path = getKnobPath()
        appearanceIconImageView()
        appearanceTimeLabel()
        setValue(value, animated: false)
    }
    
    private func getCirclePath() -> CGPath {
        return UIBezierPath(arcCenter: arcCenter,
                            radius: arcRadius,
                            startAngle: startAngle,
                            endAngle: endAngle,
                            clockwise: true).CGPath
    }
    
    private func getKnobPath() -> CGPath {
        return UIBezierPath(roundedRect: CGRectMake(arcCenter.x + arcRadius - knobRadius / 2, arcCenter.y - knobRadius / 2, knobRadius, knobRadius),
                            cornerRadius: knobRadius / 2).CGPath
    }
    
    
    // MARK: - configure
    private func configure() {
        clipsToBounds = false
        configureBackgroundLayer()
        configureProgressLayer()
        configureKnobLayer()
        configureGesture()
    }
    
    private func configureIcon() {
        iconImageView.image = icon
        appearanceIconImageView()
    }
    
    private func configureBackgroundLayer() {
        backgroundCircleLayer.frame = bounds
        layer.addSublayer(backgroundCircleLayer)
        appearanceBackgroundLayer()
    }
    
    private func configureProgressLayer() {
        progressCircleLayer.frame = bounds
        progressCircleLayer.strokeEnd = 0
        layer.addSublayer(progressCircleLayer)
        appearanceProgressLayer()
    }
    
    private func configureKnobLayer() {
        knobLayer.frame = bounds
        knobLayer.position = arcCenter
        layer.addSublayer(knobLayer)
        appearanceKnobLayer()
    }
    
    private func configureGesture() {
        let gesture = RotationGestureRecognizer(target: self, action: #selector(handleRotationGesture(_:)), arcRadius: arcRadius, knobRadius:  knobRadius)
        addGestureRecognizer(gesture)
    }
    
    private func configureType() {
        switch backingtype {
        case .normal:
            configureNormalType()
        case .timer:
            configureTimerType()
        }
    }
    
    private func configureNormalType() {
        codeView.hidden = true
        timeLabel.hidden = true
        normalView.hidden = false
        knobLayer.hidden = false
        iconImageView.hidden = false
    }
    
    private func configureTimerType() {
        codeView.hidden = false
        timeLabel.hidden = false
        normalView.hidden = true
        knobLayer.hidden = true
        iconImageView.hidden = true
    }
    
    // MARK: - appearance
    private func appearanceIconImageView() {
        iconCenterY.constant = arcRadius
    }
    
    private func appearanceTimeLabel() {
        timeCenterY.constant = arcRadius
    }
    
    private func appearanceBackgroundLayer() {
        backgroundCircleLayer.lineWidth = lineWidth
        backgroundCircleLayer.fillColor = UIColor.clearColor().CGColor
        backgroundCircleLayer.strokeColor = bgColor.CGColor
        backgroundCircleLayer.lineCap = kCALineCapRound
    }
    
    private func appearanceProgressLayer() {
        progressCircleLayer.lineWidth = lineWidth
        progressCircleLayer.fillColor = UIColor.clearColor().CGColor
        progressCircleLayer.strokeColor = highlighted ? pgHighlightedColor.CGColor : pgNormalColor.CGColor
        progressCircleLayer.lineCap = kCALineCapRound
    }
    
    private func appearanceKnobLayer() {
        knobLayer.lineWidth = 2
        knobLayer.fillColor = highlighted ? pgHighlightedColor.CGColor : pgNormalColor.CGColor
        knobLayer.strokeColor = UIColor.whiteColor().CGColor
    }
    
    private func appearanceValue() {
        
    }
    
    private func appearanceDivisa() {
        divisaLabel.text = divisa
        divisaLabel.font = divisaFont
    }
    
    
    // MARK: - update
    public func setValue(value: Float, animated: Bool) {
        self.value = delegate?.circularSlider?(self, valueForValue: value) ?? value
        
        updateLabels()
        
        setStrokeEnd(animated: animated)
        setKnobRotation(animated: animated)
    }
    
    private func setStrokeEnd(animated animated: Bool) {
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        let strokeAnimation = CABasicAnimation(keyPath: "strokeEnd")
        strokeAnimation.duration = animated ? 0.33 : 0
        strokeAnimation.repeatCount = 1
        strokeAnimation.fromValue = progressCircleLayer.presentationLayer()?.strokeEnd ?? progressCircleLayer.strokeEnd
        strokeAnimation.toValue = CGFloat(normalizedValue)
        strokeAnimation.removedOnCompletion = false
        strokeAnimation.fillMode = kCAFillModeRemoved
        strokeAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        progressCircleLayer.addAnimation(strokeAnimation, forKey: "strokeAnimation")
        progressCircleLayer.strokeEnd = CGFloat(normalizedValue)
        CATransaction.commit()
    }

    private func setKnobRotation(animated animated: Bool) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        let c: CGFloat = progressCircleLayer.presentationLayer()?.strokeEnd ?? backingKnobAngle
//        print(c)
            let n = c * angleRange + startAngle
          print(n)
        
        
        
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.duration =  0
        rotationAnimation.repeatCount = 1
        rotationAnimation.fromValue = n
        rotationAnimation.toValue = CGFloat(knobAngle)
//        rotationAnimation.removedOnCompletion = false
//        rotationAnimation.fillMode = kCAFillModeRemoved
        rotationAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        knobLayer.addAnimation(rotationAnimation, forKey: "knobRotationAnimation")
            knobLayer.transform = knobRotationTransform
        CATransaction.commit()
            backingKnobAngle = knobAngle
            
        
//        let animation = CAKeyframeAnimation(keyPath: "transform.rotation.z")
//        animation.duration = animated ? 0.66 : 0
//        animation.values = [backingKnobAngle, knobAngle]
//        knobLayer.addAnimation(animation, forKey: "knobRotationAnimation")
//        knobLayer.transform = knobRotationTransform
        CATransaction.commit()
        
//        backingKnobAngle = knobAngle
            
        
    }
    
    private func updateLabels() {
        updateValueLabel()
        updateTimeLabel()
    }
    
    private func updateValueLabel() {
        textfield.attributedText = value.formatForCurrency().sliderAttributeString(intFont: intFont, decimalFont: decimalFont)
    }
    
    private func updateTimeLabel() {
        timeLabel.text = "\(Int(value)) min"
    }
    
    
    // MARK: - gesture handler
    @objc private func handleRotationGesture(sender: AnyObject) {
        guard let gesture = sender as? RotationGestureRecognizer where backingtype == .normal else { return }
        
        if gesture.state == UIGestureRecognizerState.Began {
            cancelAnimation()
        }
        
        var rotationAngle = gesture.rotation
        if rotationAngle > knobMidAngle {
            rotationAngle -= 2 * CGFloat(M_PI)
        } else if rotationAngle < (knobMidAngle - 2 * CGFloat(M_PI)) {
            rotationAngle += 2 * CGFloat(M_PI)
        }
        rotationAngle = min(endAngle, max(startAngle, rotationAngle))
        
        guard abs(Double(rotationAngle - knobAngle)) < M_PI_2 else { return }
        
        let valueForAngle = Float(rotationAngle - startAngle) / Float(angleRange) * valueRange + minimumValue
        setValue(valueForAngle, animated: false)
        
        if gesture.state == UIGestureRecognizerState.Ended || gesture.state == UIGestureRecognizerState.Cancelled {
            // isPanning -> false
        }
    }
    
    func cancelAnimation() {
        progressCircleLayer.removeAllAnimations()
        knobLayer.removeAllAnimations()
    }
}


extension CircularSlider: UITextFieldDelegate {
    
    public func textFieldDidBeginEditing(textField: UITextField) {
        delegate?.circularSlider?(self, didBeginEditing: textfield)
    }
    
    public func textFieldDidEndEditing(textField: UITextField) {
        delegate?.circularSlider?(self, didEndEditing: textfield)
        layoutIfNeeded()
        setValue(textfield.text!.toFloat(nil), animated: true)
    }
    
    public func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        return true
    }
}
