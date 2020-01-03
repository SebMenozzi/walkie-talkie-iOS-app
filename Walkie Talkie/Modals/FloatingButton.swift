//
//  FloatingButton.swift
//  Walkie Talkie
//
//  Created by Sebastien Menozzi on 01/01/2020.
//  Copyright © 2020 Sebastien Menozzi. All rights reserved.
//

import UIKit

protocol FloatingButtonDelegate {
    func onPress()
}

class FloatingButton: NSObject {
    
    var delegate: FloatingButtonDelegate?
    
    var bottomConstraint: NSLayoutConstraint?
    
    var mainView: UIView!
    
    private let buttonWidth: CGFloat = 58
    
    private var isEnabled: Bool = true
    
    private lazy var buttonView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: buttonWidth, height: buttonWidth))
        view.backgroundColor = .black
        view.alpha = 0
        view.makeCorner(withRadius: buttonWidth / 2)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let tap = UILongPressGestureRecognizer(target: self, action: #selector(handleTap))
        tap.minimumPressDuration = 0
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        view.layer.shadowPath = UIBezierPath(roundedRect: view.bounds, cornerRadius: buttonWidth / 2).cgPath
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.shadowOffset = CGSize(width: 0, height: 0)
        view.layer.shadowRadius = 5.0
        view.layer.masksToBounds = false
        return view
    }()
    
    let buttonImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private func setupConstraints() {
        buttonView.widthAnchor.constraint(equalToConstant: buttonWidth).isActive = true
        buttonView.heightAnchor.constraint(equalToConstant: buttonWidth).isActive = true
        buttonView.rightAnchor.constraint(equalTo: mainView.rightAnchor, constant: -15).isActive = true
        
        bottomConstraint = buttonView.bottomAnchor.constraint(equalTo: mainView.safeAreaLayoutGuide.bottomAnchor, constant: -15)
        bottomConstraint?.isActive = true
        
        buttonImageView.centerYAnchor.constraint(equalTo: buttonView.centerYAnchor).isActive = true
        buttonImageView.centerXAnchor.constraint(equalTo: buttonView.centerXAnchor).isActive = true
    }
    
    private func animateOpenModal() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
            self.buttonView.alpha = 1.0
        })
    }
    
    /*
    func reloadLayout() {
        if mainView != nil {
            UIView.animate(withDuration: 0, delay: 0, options: .curveEaseOut, animations: {
                self.mainView.layoutIfNeeded()
            }, completion: nil)
        }
    }
    */
    
    func show(icon: String, iconSize: CGFloat, color: UIColor) {
        mainView.addSubview(buttonView)
        buttonView.addSubview(buttonImageView)
        
        setupConstraints()
        
        buttonView.backgroundColor = color
        
        buttonImageView.image = UIImage(named: icon)!.withRenderingMode(.alwaysTemplate)
        buttonImageView.widthAnchor.constraint(equalToConstant: iconSize).isActive = true
        buttonImageView.heightAnchor.constraint(equalToConstant: iconSize).isActive = true
        
        animateOpenModal()
    }
    
    func destroy() {
        buttonView.removeFromSuperview()
        buttonImageView.removeFromSuperview()
    }
    
    func disable() {
        isEnabled = false
        buttonView.alpha = 0.8
    }
    
    func enable() {
        isEnabled = true
        buttonView.alpha = 1.0
    }
    
    func changeBackground(color: UIColor) {
        buttonView.backgroundColor = color
    }
    
    @objc func handleTap(gesture: UILongPressGestureRecognizer) {
        if isEnabled {
            if gesture.state == .began {
                buttonView.animateButtonDown(scale: 0.9)
            } else if gesture.state == .ended {
                buttonView.animateButtonUp()
                
                guard let delegate = self.delegate else { return }
                delegate.onPress()
            }
        }
    }
    
}
