//
//  Extensions.swift
//  Walkie Talkie
//
//  Created by Sebastien Menozzi on 26/12/2019.
//  Copyright © 2019 Sebastien Menozzi. All rights reserved.
//

import UIKit

extension UIColor {
    
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat) {
        self.init(red: r / 255, green: g / 255, blue: b / 255, alpha: 1.0)
    }
    
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) {
        self.init(red: r / 255, green: g / 255, blue: b / 255, alpha: a)
    }
    
}

extension UIView {
    
    func makeCorner(withRadius radius: CGFloat) {
        layer.cornerRadius = radius
        layer.masksToBounds = true
        layer.isOpaque = false
    }
    
}

extension UIView {
    
    func animateButtonDown(scale: CGFloat) {
        UIView.animate(withDuration: 0.1, delay: 0.0, options: [.allowUserInteraction, .curveEaseIn], animations: {
            self.transform = CGAffineTransform(scaleX: scale, y: scale)
        }, completion: nil)
    }
    
    func animateButtonUp() {
        UIView.animate(withDuration: 0.1, delay: 0.0, options: [.allowUserInteraction, .curveEaseOut], animations: {
            self.transform = CGAffineTransform.identity
        }, completion: nil)
    }
    
}

extension String {

    func withoutWhitespace() -> String {
        return self.replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: "\r", with: "").replacingOccurrences(of: "\0", with: "")
    }
    
}

extension Int {
    
    var degreesToRadians: CGFloat {
        return CGFloat(self) * .pi / 180.0
    }
    
}
