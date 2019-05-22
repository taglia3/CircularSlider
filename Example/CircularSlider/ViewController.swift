//
//  ViewController.swift
//  CircularSliderExample
//
//  Created by Matteo Tagliafico on 02/09/16.
//  Copyright © 2016 Matteo Tagliafico. All rights reserved.
//

import UIKit
import CircularSlider

class ViewController: UIViewController {
    
    // MARK: - outlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var circularSlider: CircularSlider!
    
    
    // MARK: - view lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCircularSlider()
        registerForKeyboardNotifications()
        setupTapGesture()
    }
    
    
    // MARK: - methods
    fileprivate func setupCircularSlider() {
        circularSlider.delegate = self
    }
    
    fileprivate func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    
    // MARK: - keyboard handler
    fileprivate func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil )
    }
    
    @objc fileprivate func keyboardWillShow(_ notification: Notification) {
        adjustInsetForKeyboardShow(true, notification: notification)
    }
    
    @objc fileprivate func keyboardWillHide(_ notification: Notification) {
        adjustInsetForKeyboardShow(false, notification: notification)
    }
    
    fileprivate func adjustInsetForKeyboardShow(_ show: Bool, notification: Notification) {
        guard let value = (notification as NSNotification).userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue else { return }
        let keyboardFrame = value.cgRectValue
        let adjustmentHeight = (keyboardFrame.height + 150) * (show ? 1 : -1)
        scrollView.contentInset.bottom += adjustmentHeight
        scrollView.scrollIndicatorInsets.bottom += adjustmentHeight
    }
    
    @objc fileprivate func hideKeyboard() {
        view.endEditing(true)
    }
    
    
    // MARK: - actions
    @IBAction func decrementAction(_ sender: UIButton) {
        circularSlider.setValue(circularSlider.value - 50, animated: true)
    }
    
    @IBAction func incrementAction(_ sender: UIButton) {
        circularSlider.setValue(circularSlider.value + 50, animated: true)
    }
}


// MARK: - CircularSliderDelegate
extension ViewController: CircularSliderDelegate {
    func circularSlider(_ circularSlider: CircularSlider, valueForValue value: Float) -> Float {
        return floorf(value)
    }
}
