//
//  AppNavigationController.swift
//  Walkie Talkie
//
//  Created by Sebastien Menozzi on 02/01/2020.
//  Copyright © 2020 Sebastien Menozzi. All rights reserved.
//

import UIKit

class AppNavigationController: UINavigationController {
    private var themedStatusBarStyle: UIStatusBarStyle?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return themedStatusBarStyle ?? super.preferredStatusBarStyle
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpTheming()
    }
}

extension AppNavigationController: Themed {
    
    func applyTheme(_ theme: AppTheme) {
        
        themedStatusBarStyle = .lightContent
        setNeedsStatusBarAppearanceUpdate()
        
        navigationBar.barTintColor = theme.backgroundColor
        navigationBar.tintColor = UIColor.white
        navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.white
        ]
        
        navigationBar.setValue(true, forKey: "hidesShadow")
        navigationBar.shadowImage = UIImage()
        navigationBar.isTranslucent = false
        
    }
    
}
