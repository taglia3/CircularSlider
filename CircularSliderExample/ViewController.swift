//
//  ViewController.swift
//  CircularSliderExample
//
//  Created by Matteo Tagliafico on 02/09/16.
//  Copyright © 2016 Matteo Tagliafico. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var circularSlider: CircularSlider!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        circularSlider.delegate = self
        setupTapGesture()
    }
    
    func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func decrementAction(sender: UIButton) {
        let currentValue = circularSlider.value
        circularSlider.setValue(value: currentValue - 50, animated: true)
    }
    
    @IBAction func incrementAction(sender: UIButton) {
        let currentValue = circularSlider.value
        circularSlider.setValue(value: currentValue + 50, animated: true)
    }
}

extension ViewController: CircularSliderDelegate {
    func circularSlider(circularSlider: CircularSlider, valueForValue value: Float) -> Float {
        print("New value is \(value)")
        return Float(Int(value))
    }
}

