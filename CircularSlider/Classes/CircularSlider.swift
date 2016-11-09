//
//  CircularSlider.swift
//  CircularSliderExample
//
//  Created by Matteo Tagliafico on 02/09/16.
//  Copyright © 2016 Matteo Tagliafico. All rights reserved.
//

import Foundation
import UIKit


@objc public protocol CircularSliderDelegate: NSObjectProtocol {
    @objc optional func circularSlider(_ circularSlider: CircularSlider, valueForValue value: Float) -> Float
    @objc optional func circularSlider(_ circularSlider: CircularSlider, didBeginEditing textfield: UITextField)
    @objc optional func circularSlider(_ circularSlider: CircularSlider, didEndEditing textfield: UITextField)
    //  optional func circularSlider(circularSlider: CircularSlider, attributeTextForValue value: Float) -> NSAttributedString
}


@IBDesignable
open class CircularSlider: UIView {
    
    // MARK: - outlets
    @IBOutlet fileprivate weak var iconImageView: UIImageView!
    @IBOutlet fileprivate weak var iconCenterY: NSLayoutConstraint!
    @IBOutlet fileprivate weak var centeredView: UIView!
    @IBOutlet fileprivate weak var titleLabel: UILabel!
    @IBOutlet fileprivate weak var textfield: UITextField! {
        didSet {
            addDoneButtonOnKeyboard()
        }
    }
    @IBOutlet fileprivate weak var divisaLabel: UILabel!
    
    
    // MARK: - properties
    open weak var delegate: CircularSliderDelegate?
    
    fileprivate var containerView: UIView!
    fileprivate var nibName = "CircularSlider"
    fileprivate var backgroundCircleLayer = CAShapeLayer()
    fileprivate var progressCircleLayer = CAShapeLayer()
    fileprivate var knobLayer = CAShapeLayer()
    fileprivate var backingValue: Float = 0
    fileprivate var backingKnobAngle: CGFloat = 0
    fileprivate var rotationGesture: RotationGestureRecognizer?
    fileprivate var backingFractionDigits: NSInteger = 2
    fileprivate let maxFractionDigits: NSInteger = 4
    fileprivate var startAngle: CGFloat {
        return -CGFloat(M_PI_2) + radiansOffset
    }
    fileprivate var endAngle: CGFloat {
        return 3 * CGFloat(M_PI_2) - radiansOffset
    }
    fileprivate var angleRange: CGFloat {
        return endAngle - startAngle
    }
    fileprivate var valueRange: Float {
        return maximumValue - minimumValue
    }
    fileprivate var arcCenter: CGPoint {
        return CGPoint(x: frame.width / 2, y: frame.height / 2)
    }
    fileprivate var arcRadius: CGFloat {
        return min(frame.width,frame.height) / 2 - lineWidth / 2
    }
    fileprivate var normalizedValue: Float {
        return (value - minimumValue) / (maximumValue - minimumValue)
    }
    fileprivate var knobAngle: CGFloat {
        return CGFloat(normalizedValue) * angleRange + startAngle
    }
    fileprivate var knobMidAngle: CGFloat {
        return (2 * CGFloat(M_PI) + startAngle - endAngle) / 2 + endAngle
    }
    fileprivate var knobRotationTransform: CATransform3D {
        return CATransform3DMakeRotation(knobAngle, 0.0, 0.0, 1)
    }
    fileprivate var intFont = UIFont.systemFont(ofSize: 42)
    fileprivate var decimalFont = UIFont.systemFont(ofSize: 42)
    fileprivate var divisaFont = UIFont.systemFont(ofSize: 26)
    
    
    @IBInspectable
    open var title: String = "Title" {
        didSet {
            titleLabel.text = title
        }
    }
    @IBInspectable
    open var radiansOffset: CGFloat = 0 {
        didSet {
            setNeedsDisplay()
        }
    }
    @IBInspectable
    open var icon: UIImage? = UIImage() {
        didSet {
            configureIcon()
        }
    }
    @IBInspectable
    open var divisa: String = "" {
        didSet {
            appearanceDivisa()
        }
    }
    @IBInspectable
    open var value: Float {
        get {
            return backingValue
        }
        set {
            backingValue = min(maximumValue, max(minimumValue, newValue))
        }
    }
    @IBInspectable
    open var minimumValue: Float = 0
    @IBInspectable
    open var maximumValue: Float = 500
    @IBInspectable
    open var lineWidth: CGFloat = 5 {
        didSet {
            appearanceBackgroundLayer()
            appearanceProgressLayer()
        }
    }
    @IBInspectable
    open var bgColor: UIColor = UIColor.lightGray {
        didSet {
            appearanceBackgroundLayer()
        }
    }
    @IBInspectable
    open var pgNormalColor: UIColor = UIColor.darkGray {
        didSet {
            appearanceProgressLayer()
        }
    }
    @IBInspectable
    open var pgHighlightedColor: UIColor = UIColor.green {
        didSet {
            appearanceProgressLayer()
        }
    }
    @IBInspectable
    open var knobRadius: CGFloat = 20 {
        didSet {
            appearanceKnobLayer()
        }
    }
    @IBInspectable
    open var highlighted: Bool = true {
        didSet {
            appearanceProgressLayer()
            appearanceKnobLayer()
        }
    }
    @IBInspectable
    open var hideLabels: Bool = false {
        didSet {
            setLabelsHidden(self.hideLabels)
        }
    }
    @IBInspectable
    open var fractionDigits: NSInteger {
        get {
            return backingFractionDigits
        }
        set {
            backingFractionDigits = min(maxFractionDigits, max(0, newValue))
        }
    }
    @IBInspectable
    open var customDecimalSeparator: String? = nil {
        didSet {
            if let c = self.customDecimalSeparator, c.characters.count > 1 {
                self.customDecimalSeparator = nil
            }
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
    
    fileprivate func xibSetup() {
        containerView = loadViewFromNib()
        containerView.frame = bounds
        containerView.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        addSubview(containerView)
    }
    
    fileprivate func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
        return view
    }
    
    
    // MARK: - drawing methods
    override open func draw(_ rect: CGRect) {
        print("drawRect")
        backgroundCircleLayer.bounds = bounds
        progressCircleLayer.bounds = bounds
        knobLayer.bounds = bounds
        
        backgroundCircleLayer.position = arcCenter
        progressCircleLayer.position = arcCenter
        knobLayer.position = arcCenter
        
        rotationGesture?.arcRadius = arcRadius
        
        backgroundCircleLayer.path = getCirclePath()
        progressCircleLayer.path = getCirclePath()
        knobLayer.path = getKnobPath()
        
        appearanceIconImageView()
        setValue(value, animated: false)
    }
    
    
    fileprivate func getCirclePath() -> CGPath {
        return UIBezierPath(arcCenter: arcCenter,
                            radius: arcRadius,
                            startAngle: startAngle,
                            endAngle: endAngle,
                            clockwise: true).cgPath
    }
    
    fileprivate func getKnobPath() -> CGPath {
        return UIBezierPath(roundedRect:
            CGRect(x: arcCenter.x + arcRadius - knobRadius / 2, y: arcCenter.y - knobRadius / 2, width: knobRadius, height: knobRadius),
                            cornerRadius: knobRadius / 2).cgPath
    }
    
    
    // MARK: - configure
    fileprivate func configure() {
        clipsToBounds = false
        configureBackgroundLayer()
        configureProgressLayer()
        configureKnobLayer()
        configureGesture()
        configureFont()
    }
    
    fileprivate func configureIcon() {
        iconImageView.image = icon
        appearanceIconImageView()
    }
    
    fileprivate func configureBackgroundLayer() {
        backgroundCircleLayer.frame = bounds
        layer.addSublayer(backgroundCircleLayer)
        appearanceBackgroundLayer()
    }
    
    fileprivate func configureProgressLayer() {
        progressCircleLayer.frame = bounds
        progressCircleLayer.strokeEnd = 0
        layer.addSublayer(progressCircleLayer)
        appearanceProgressLayer()
    }
    
    fileprivate func configureKnobLayer() {
        knobLayer.frame = bounds
        knobLayer.position = arcCenter
        layer.addSublayer(knobLayer)
        appearanceKnobLayer()
    }
    
    fileprivate func configureGesture() {
        rotationGesture = RotationGestureRecognizer(target: self, action: #selector(handleRotationGesture(_:)), arcRadius: arcRadius, knobRadius:  knobRadius)
        addGestureRecognizer(rotationGesture!)
    }
    
    fileprivate func configureFont() {
        if #available(iOS 8.2, *) {
            intFont = UIFont.systemFont(ofSize: 42, weight: UIFontWeightRegular)
            decimalFont = UIFont.systemFont(ofSize: 42, weight: UIFontWeightThin)
            divisaFont = UIFont.systemFont(ofSize: 26, weight: UIFontWeightThin)
        }
    }
    
    
    // MARK: - appearance
    fileprivate func appearanceIconImageView() {
        iconCenterY.constant = arcRadius
    }
    
    fileprivate func appearanceBackgroundLayer() {
        backgroundCircleLayer.lineWidth = lineWidth
        backgroundCircleLayer.fillColor = UIColor.clear.cgColor
        backgroundCircleLayer.strokeColor = bgColor.cgColor
        backgroundCircleLayer.lineCap = kCALineCapRound
    }
    
    fileprivate func appearanceProgressLayer() {
        progressCircleLayer.lineWidth = lineWidth
        progressCircleLayer.fillColor = UIColor.clear.cgColor
        progressCircleLayer.strokeColor = highlighted ? pgHighlightedColor.cgColor : pgNormalColor.cgColor
        progressCircleLayer.lineCap = kCALineCapRound
    }
    
    fileprivate func appearanceKnobLayer() {
        knobLayer.lineWidth = 2
        knobLayer.fillColor = highlighted ? pgHighlightedColor.cgColor : pgNormalColor.cgColor
        knobLayer.strokeColor = UIColor.white.cgColor
    }
    
    fileprivate func appearanceDivisa() {
        divisaLabel.text = divisa
        divisaLabel.font = divisaFont
    }
    
    
    // MARK: - update
    open func setValue(_ value: Float, animated: Bool) {
        self.value = delegate?.circularSlider?(self, valueForValue: value) ?? value
        
        updateLabels()
        
        setStrokeEnd(animated: animated)
        setKnobRotation(animated: animated)
    }
    
    fileprivate func setStrokeEnd(animated: Bool) {
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        let strokeAnimation = CABasicAnimation(keyPath: "strokeEnd")
        strokeAnimation.duration = animated ? 0.66 : 0
        strokeAnimation.repeatCount = 1
        strokeAnimation.fromValue = progressCircleLayer.strokeEnd
        strokeAnimation.toValue = CGFloat(normalizedValue)
        strokeAnimation.isRemovedOnCompletion = false
        strokeAnimation.fillMode = kCAFillModeRemoved
        strokeAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        progressCircleLayer.add(strokeAnimation, forKey: "strokeAnimation")
        progressCircleLayer.strokeEnd = CGFloat(normalizedValue)
        CATransaction.commit()
    }
    
    fileprivate func setKnobRotation(animated: Bool) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        let animation = CAKeyframeAnimation(keyPath: "transform.rotation.z")
        animation.duration = animated ? 0.66 : 0
        animation.values = [backingKnobAngle, knobAngle]
        knobLayer.add(animation, forKey: "knobRotationAnimation")
        knobLayer.transform = knobRotationTransform
        
        CATransaction.commit()
        
        backingKnobAngle = knobAngle
    }
    
    fileprivate func setLabelsHidden(_ isHidden: Bool) {
        centeredView.isHidden = isHidden
    }
    
    fileprivate func updateLabels() {
        updateValueLabel()
    }
    
    fileprivate func updateValueLabel() {
        textfield.attributedText = value.formatWithFractionDigits(fractionDigits, customDecimalSeparator: customDecimalSeparator).sliderAttributeString(intFont: intFont, decimalFont: decimalFont, customDecimalSeparator: customDecimalSeparator )
    }
    
    
    // MARK: - gesture handler
    @objc fileprivate func handleRotationGesture(_ sender: AnyObject) {
        guard let gesture = sender as? RotationGestureRecognizer else { return }
        
        if gesture.state == UIGestureRecognizerState.began {
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
    }
    
    func cancelAnimation() {
        progressCircleLayer.removeAllAnimations()
        knobLayer.removeAllAnimations()
    }
    
    
    // MARK:- methods
    open override func becomeFirstResponder() -> Bool {
        return textfield.becomeFirstResponder()
    }
    
    open override func resignFirstResponder() -> Bool {
        return textfield.resignFirstResponder()
    }
    
    fileprivate func addDoneButtonOnKeyboard() {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton: UIBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(resignFirstResponder))
        
        doneToolbar.barStyle = UIBarStyle.default
        doneToolbar.items = [flexSpace, doneButton]
        doneToolbar.sizeToFit()
        
        textfield.inputAccessoryView = doneToolbar
    }
}


// MARK: - UITextFieldDelegate
extension CircularSlider: UITextFieldDelegate {
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        delegate?.circularSlider?(self, didBeginEditing: textfield)
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        delegate?.circularSlider?(self, didEndEditing: textfield)
        layoutIfNeeded()
        setValue(textfield.text!.toFloat(), animated: true)
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        
        if newString.characters.count > 0 {
            
            let fmt = NumberFormatter()
            let scanner: Scanner = Scanner(string:newString.replacingOccurrences(of: customDecimalSeparator ?? fmt.decimalSeparator, with: "."))
            let isNumeric = scanner.scanDecimal(nil) && scanner.isAtEnd
            
            if isNumeric {
                var decimalFound = false
                var charactersAfterDecimal = 0
                
                
                
                for ch in newString.characters.reversed() {
                    if ch == fmt.decimalSeparator.characters.first {
                        decimalFound = true
                        break
                    }
                    charactersAfterDecimal += 1
                }
                if decimalFound && charactersAfterDecimal > fractionDigits {
                    return false
                }
                else {
                    return true
                }
            }
            else {
                return false
            }
        }
        else {
            return true
        }
    }
}
