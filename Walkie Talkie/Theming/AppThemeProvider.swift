//
//  AppThemeProvider.swift
//  Walkie Talkie
//
//  Created by Sebastien Menozzi on 01/01/2020.
//  Copyright © 2020 Sebastien Menozzi. All rights reserved.
//

import UIKit

final class AppThemeProvider: ThemeProvider {
    
    static let shared: AppThemeProvider = .init()
    
    private var theme: SubscribableValue<AppTheme>
    private var availableThemes: [AppTheme] = [ .basic, .christmas, .purple, .pink ]
    
    var currentTheme: AppTheme {
        get {
            return theme.value
        }
        set {
            setNewTheme(newValue)
        }
    }
    
    init() {
        let themeMemory = UserDefaults.standard.string(forKey: "theme")
        
        if themeMemory == "christmas" {
            theme = SubscribableValue<AppTheme>(value: .christmas)
        } else if themeMemory == "purple" {
            theme = SubscribableValue<AppTheme>(value: .purple)
        } else if themeMemory == "pink" {
            theme = SubscribableValue<AppTheme>(value: .pink)
        } else {
            theme = SubscribableValue<AppTheme>(value: .basic)
        }
    }
    
    private func setNewTheme(_ newTheme: AppTheme) {
        let window = UIApplication.shared.delegate!.window!!
        UIView.transition(
            with: window,
            duration: 0.3,
            options: [.transitionCrossDissolve],
            animations: {
                self.theme.value = newTheme
        },
            completion: nil
        )
    }
    
    func subscribeToChanges(_ object: AnyObject, handler: @escaping (AppTheme) -> Void) {
        theme.subscribe(object, using: handler)
    }
    
}

extension Themed where Self: AnyObject {
    
    var themeProvider: AppThemeProvider {
        return AppThemeProvider.shared
    }
    
}
