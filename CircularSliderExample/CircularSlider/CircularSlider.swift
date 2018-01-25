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
    @objc optional func circularSlider(circularSlider: CircularSlider, valueForValue value: Float) -> Float
//    optional func circularSlider(circularSlider: CircularSlider, attributeTextForValue value: Float) -> NSAttributedString
    @objc optional func circularSlider(circularSlider: CircularSlider, didBeginEditing textfield: UITextField)
    @objc optional func circularSlider(circularSlider: CircularSlider, didEndEditing textfield: UITextField)
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
        return -CGFloat(Double.pi/2) + radiansOffset
    }
    private var endAngle: CGFloat {
        return 3 * CGFloat(Double.pi/2) - radiansOffset
    }
    private var angleRange: CGFloat {
        return endAngle - startAngle
    }
    private var valueRange: Float {
        return maximumValue - minimumValue
    }
    private var arcCenter: CGPoint {
        return CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
    }
    private var arcRadius: CGFloat {
        return min(frame.size.width, frame.size.height) / 2 - lineWidth / 2
    }
    private var normalizedValue: Float {
        return (value - minimumValue) / (maximumValue - minimumValue)
    }
    private var knobAngle: CGFloat {
        return CGFloat(normalizedValue) * angleRange + startAngle
    }
    private var knobMidAngle: CGFloat {
        return (2 * CGFloat(Double.pi) + startAngle - endAngle) / 2 + endAngle
    }
    private var knobRotationTransform: CATransform3D {
        return CATransform3DMakeRotation(knobAngle, 0.0, 0.0, 1)
    }
    private var numberOfDecimalDigits = 2 {
        didSet {
            appearanceValue()
        }
    }
    private var intFont = UIFont.systemFont(ofSize: 42, weight: UIFont.Weight.regular) {
        didSet {
            appearanceValue()
        }
    }
    private var decimalFont = UIFont.systemFont(ofSize: 42, weight: UIFont.Weight.thin) {
        didSet {
            appearanceValue()
        }
    }
    private var divisaFont = UIFont.systemFont(ofSize: 26, weight: UIFont.Weight.thin) {
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
    public var bgColor: UIColor = UIColor.lightGray {
        didSet {
            appearanceBackgroundLayer()
        }
    }
    @IBInspectable
    public var pgNormalColor: UIColor = UIColor.darkGray {
        didSet {
            appearanceProgressLayer()
        }
    }
    @IBInspectable
    public var pgHighlightedColor: UIColor = UIColor.green {
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
        containerView.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        addSubview(containerView)
    }
    
    private func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: CircularSlider.self)
        let nib = UINib(nibName: nibName, bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
        return view
    }
    
    
    // MARK: - drawing methods
    override public func draw(_ rect: CGRect) {
        print("drawRect")
        backgroundCircleLayer.path = getCirclePath()
        progressCircleLayer.path = getCirclePath()
        knobLayer.path = getKnobPath()
        appearanceIconImageView()
        appearanceTimeLabel()
        setValue(value: value, animated: false)
    }
    
    private func getCirclePath() -> CGPath {
        return UIBezierPath(arcCenter: arcCenter,
                            radius: arcRadius,
                            startAngle: startAngle,
                            endAngle: endAngle,
                            clockwise: true).cgPath
    }
    
    private func getKnobPath() -> CGPath {
        return UIBezierPath(roundedRect: CGRect(x: arcCenter.x + arcRadius - knobRadius / 2,
                                                y: arcCenter.y - knobRadius / 2,
                                                width: knobRadius,
                                                height: knobRadius),
                            cornerRadius: knobRadius / 2).cgPath
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
        let gesture = RotationGestureRecognizer(target: self,
                                                action: #selector(handleRotationGesture(sender:)),
                                                arcRadius: arcRadius,
                                                knobRadius:  knobRadius)
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
        codeView.isHidden = true
        timeLabel.isHidden = true
        normalView.isHidden = false
        knobLayer.isHidden = false
        iconImageView.isHidden = false
    }
    
    private func configureTimerType() {
        codeView.isHidden = false
        timeLabel.isHidden = false
        normalView.isHidden = true
        knobLayer.isHidden = true
        iconImageView.isHidden = true
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
        backgroundCircleLayer.fillColor = UIColor.clear.cgColor
        backgroundCircleLayer.strokeColor = bgColor.cgColor
        backgroundCircleLayer.lineCap = kCALineCapRound
    }
    
    private func appearanceProgressLayer() {
        progressCircleLayer.lineWidth = lineWidth
        progressCircleLayer.fillColor = UIColor.clear.cgColor
        progressCircleLayer.strokeColor = highlighted ? pgHighlightedColor.cgColor : pgNormalColor.cgColor
        progressCircleLayer.lineCap = kCALineCapRound
    }
    
    private func appearanceKnobLayer() {
        knobLayer.lineWidth = 2
        knobLayer.fillColor = highlighted ? pgHighlightedColor.cgColor : pgNormalColor.cgColor
        knobLayer.strokeColor = UIColor.white.cgColor
    }
    
    private func appearanceValue() {
        
    }
    
    private func appearanceDivisa() {
        divisaLabel.text = divisa
        divisaLabel.font = divisaFont
    }
    
    
    // MARK: - update
    public func setValue(value: Float, animated: Bool) {
        self.value = delegate?.circularSlider!(circularSlider: self, valueForValue: value) ?? value
        
        updateLabels()
        
        setStrokeEnd(animated: animated)
        setKnobRotation(animated: animated)
    }
    
    private func setStrokeEnd(animated: Bool) {
        
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

    private func setKnobRotation(animated: Bool) {
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
        guard let gesture = sender as? RotationGestureRecognizer, backingtype == .normal else { return }
        
        if gesture.state == UIGestureRecognizerState.began {
            cancelAnimation()
        }
        
        var rotationAngle = gesture.rotation
        if rotationAngle > knobMidAngle {
            rotationAngle -= 2 * CGFloat(Double.pi)
        } else if rotationAngle < (knobMidAngle - 2 * CGFloat(Double.pi)) {
            rotationAngle += 2 * CGFloat(Double.pi)
        }
        rotationAngle = min(endAngle, max(startAngle, rotationAngle))
        
        guard abs(Double(rotationAngle - knobAngle)) < Double.pi / 2 else { return }
        
        let valueForAngle = Float(rotationAngle - startAngle) / Float(angleRange) * valueRange + minimumValue
        setValue(value: valueForAngle, animated: false)
        
        if gesture.state == UIGestureRecognizerState.ended || gesture.state == UIGestureRecognizerState.cancelled {
            // isPanning -> false
        }
    }
    
    func cancelAnimation() {
        progressCircleLayer.removeAllAnimations()
        knobLayer.removeAllAnimations()
    }
}


extension CircularSlider: UITextFieldDelegate {
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        delegate?.circularSlider?(circularSlider: self, didBeginEditing: textField)
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        delegate?.circularSlider?(circularSlider: self, didEndEditing: textField)
        layoutIfNeeded()
        setValue(value: textfield.text!.toFloat(localeIdentifier: nil), animated: true)
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return true
    }
}
