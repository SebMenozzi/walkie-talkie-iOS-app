//
//  CustomNavigationTitleView.swift
//  Walkie Talkie
//
//  Created by Sebastien Menozzi on 01/01/2020.
//  Copyright © 2020 Sebastien Menozzi. All rights reserved.
//

import UIKit

protocol CustomNavigationTitleViewDelegate {
    func didGoBack()
    func didGoMenu()
}

class CustomNavigationTitleView: UIView {
    
    let offset: CGFloat = UIDevice.current.hasNotch ? -12 : -8
    
    var delegate: CustomNavigationTitleViewDelegate?
    
    private lazy var mainView = UIView(frame: frame)
    
    let searchBackgroundViewHeightMargin: CGFloat = UIDevice.current.hasNotch ? 0 : 4
    
    private lazy var backView: UIView = {
        let view = UIView()
        let tap = UILongPressGestureRecognizer(target: self, action: #selector(handleGoBack))
        tap.minimumPressDuration = 0
        view.addGestureRecognizer(tap)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let backImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "back")?.withRenderingMode(.alwaysTemplate)
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = UIColor.white.withAlphaComponent(0.4)
        return imageView
    }()
    
    @objc func handleGoBack(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            gesture.view?.animateButtonDown(scale: 1.2)
        } else if gesture.state == .ended {
            gesture.view?.animateButtonUp()
            
            delegate?.didGoBack()
        }
    }
    
    private lazy var menuView: UIView = {
        let view = UIView()
        let tap = UILongPressGestureRecognizer(target: self, action: #selector(handleTapSettings))
        tap.minimumPressDuration = 0
        view.addGestureRecognizer(tap)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let menuImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = UIColor.white.withAlphaComponent(0.4)
        return imageView
    }()
    
    @objc private func handleTapSettings(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            menuImageView.animateButtonDown(scale: 1.2)
        } else if gesture.state == .ended {
            menuImageView.animateButtonUp()
            
            delegate?.didGoMenu()
        }
    }
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: CGRect(x: offset, y: 0, width: frame.width, height: frame.height))
        
        addSubview(mainView)
        
        mainView.addSubview(titleLabel)
        titleLabel.centerXAnchor.constraint(equalTo: mainView.centerXAnchor).isActive = true
        titleLabel.widthAnchor.constraint(equalTo: mainView.widthAnchor, multiplier: 0.6).isActive = true
        titleLabel.heightAnchor.constraint(equalTo: mainView.heightAnchor).isActive = true
        
        mainView.addSubview(backView)
        backView.leadingAnchor.constraint(equalTo: mainView.leadingAnchor).isActive = true
        backView.heightAnchor.constraint(equalTo: mainView.heightAnchor).isActive = true
        backView.widthAnchor.constraint(equalTo: mainView.heightAnchor, multiplier: 2).isActive = true
        
        backView.addSubview(backImageView)
        backImageView.centerInSuperview()
        
        mainView.addSubview(menuView)
        menuView.trailingAnchor.constraint(equalTo: mainView.trailingAnchor).isActive = true
        menuView.heightAnchor.constraint(equalTo: mainView.heightAnchor).isActive = true
        menuView.widthAnchor.constraint(equalTo: mainView.heightAnchor, multiplier: 2).isActive = true
        
        menuView.addSubview(menuImageView)
        menuImageView.centerInSuperview()
    }
    
    func hideBackButton() {
        backView.isHidden = true
    }
    
    func hideMenuButton() {
        menuView.isHidden = true
    }
    
    func setupMenuIcon(image: String, imageSize: CGFloat) {
        menuImageView.image = UIImage(named: image)?.withRenderingMode(.alwaysTemplate)
        menuImageView.widthAnchor.constraint(equalToConstant: imageSize).isActive = true
        menuImageView.heightAnchor.constraint(equalToConstant: imageSize).isActive = true
    }
    
    func setupTitle(title: String, fontSize: CGFloat = 20) {
        titleLabel.text = title
        titleLabel.font = UIFont(name: "GothamRounded-Medium", size: fontSize)
    }
    
    func changeBackIconImage(image: String) {
        backImageView.image = UIImage(named: image)?.withRenderingMode(.alwaysTemplate)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    override var intrinsicContentSize: CGSize {
        return UIView.layoutFittingExpandedSize
    }
}
