//
//  ShakeTextField.swift
//  On The Map
//
//  Created by Bryan's Air on 2/12/19.
//  Copyright © 2019 Bryborg Inc. All rights reserved.
//

import UIKit

class ShakeTextField: UITextField {
    
    func errorShake() {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.05
        animation.repeatCount = 5
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: self.center.x - 4, y: self.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: self.center.x + 4, y: self.center.y))
        
        self.layer.add(animation, forKey: "position")
    }
}
