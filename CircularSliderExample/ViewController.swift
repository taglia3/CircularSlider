//
//  ViewController.swift
//  CircularSliderExample
//
//  Created by Matteo Tagliafico on 02/09/16.
//  Copyright © 2016 Matteo Tagliafico. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    // MARK: - outlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var circularSlider: CircularSlider!
    
    
    // MARK: - view lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        circularSlider.delegate = self
        registerForKeyboardNotifications()
        setupTapGesture()
    }
    
    
    // MARK: - methods
    func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    
    // MARK: - keyboard handler
    private func registerForKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil )
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        adjustInsetForKeyboardShow(true, notification: notification)
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        adjustInsetForKeyboardShow(false, notification: notification)
    }
    
    private func adjustInsetForKeyboardShow(show: Bool, notification: NSNotification) {
        guard let value = notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue else { return }
        let keyboardFrame = value.CGRectValue()
        let adjustmentHeight = (CGRectGetHeight(keyboardFrame) + 150) * (show ? 1 : -1)
        scrollView.contentInset.bottom += adjustmentHeight
        scrollView.scrollIndicatorInsets.bottom += adjustmentHeight
    }
    
    @objc private func hideKeyboard() {
        view.endEditing(true)
    }
    
    
    // MARK: - actions
    @IBAction func decrementAction(sender: UIButton) {
        let currentValue = circularSlider.value
        circularSlider.setValue(currentValue - 50, animated: true)
    }
    
    @IBAction func incrementAction(sender: UIButton) {
        let currentValue = circularSlider.value
        circularSlider.setValue(currentValue + 50, animated: true)
    }
}

extension ViewController: CircularSliderDelegate {
    func circularSlider(circularSlider: CircularSlider, valueForValue value: Float) -> Float {
        print("New value is \(value)")
        return Float(Int(value))
    }
}

