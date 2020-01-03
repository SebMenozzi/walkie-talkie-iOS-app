//
//  SettingsSection.swift
//  Walkie Talkie
//
//  Created by Sebastien Menozzi on 01/01/2020.
//  Copyright © 2020 Sebastien Menozzi. All rights reserved.
//

import Foundation

let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0"

enum SettingsSection: Int, CaseIterable, CustomStringConvertible {
    case Theme
    case App
    
    var description: String {
        switch self {
            case .Theme: return "\(NSLocalizedString("THEME", comment: ""))"
            case .App: return "\(NSLocalizedString("APP", comment: "")) (v\(version))"
        }
    }
}

enum SettingsThemeOptions: Int, CaseIterable, SettingsItemSection {
    case basic
    case christmas
    case purple
    case emerald
    case pink
    
    // info
    var icon: String {
        switch self {
            case .basic: return ""
            case .christmas: return ""
            case .purple: return ""
            case .emerald: return ""
            case .pink: return ""
        }
    }
    var description: String {
        switch self {
            case .basic: return NSLocalizedString("Basic theme", comment: "")
            case .christmas: return NSLocalizedString("Christmas theme 🎄", comment: "")
            case .purple: return NSLocalizedString("Purple theme 🟣", comment: "")
            case .emerald: return NSLocalizedString("Emerald theme 🟢", comment: "")
            case .pink: return NSLocalizedString("Pink theme 🌸", comment: "")
        }
    }
    
    // value
    var value: String { return "" }
    var hasValue: Bool { return false }
    
    // switch
    var switchValue: Bool {
        get {
            return false
        }
        set {
            return
        }
    }
    var hasSwitch: Bool { return false }
    
    // picture
    var pictureUrl: String {
        get {
            return ""
        }
        set {
            return
        }
    }
    var hasPicture: Bool { return false }
    
    // input
    var inputValue: String {
        get {
            return ""
        }
        set {
            return
        }
    }
    var placeholder: String { return "" }
    var hasInput: Bool { return false }
    
    // arrow
    var hasArrow: Bool { return false }
    
    // destructive
    var isDestructive: Bool { return false }
    
    // disabled
    var isDisabled: Bool { return false }
}


enum SettingsAppOptions: Int, CaseIterable, SettingsItemSection {
    case snapchat
    case instagram
    case contact
    case terms
    
    // info
    var icon: String {
        switch self {
            case .snapchat: return "snapchat"
            case .instagram: return "instagram"
            case .contact: return ""
            case .terms: return ""
        }
    }
    var description: String {
        switch self {
            case .snapchat: return NSLocalizedString("Add us on Snapchat", comment: "")
            case .instagram: return NSLocalizedString("Follow us on Instagram", comment: "")
            case .contact: return NSLocalizedString("Contact us", comment: "")
            case .terms: return NSLocalizedString("Terms of Use", comment: "")
        }
    }
    
    // value
    var value: String { return "" }
    var hasValue: Bool { return false }
    
    // switch
    var switchValue: Bool {
        get {
            switch self {
                case .snapchat: return false
                case .instagram: return false
                case .contact: return false
                case .terms: return false
            }
        }
        set {
            switch self {
                case .snapchat: return
                case .instagram: return
                case .contact: return
                case .terms: return
            }
        }
    }
    var hasSwitch: Bool {
        switch self {
            case .snapchat: return false
            case .instagram: return false
            case .contact: return false
            case .terms: return false
        }
    }
    
    // picture
    var pictureUrl: String {
        get {
            return ""
        }
        set {
            return
        }
    }
    var hasPicture: Bool { return false }
    
    // input
    var inputValue: String {
        get {
            return ""
        }
        set {
            return
        }
    }
    var placeholder: String { return "" }
    var hasInput: Bool { return false }
    
    // arrow
    var hasArrow: Bool {
        switch self {
            case .snapchat: return true
            case .instagram: return true
            case .contact: return true
            case .terms: return true
        }
    }
    
    // destructive
    var isDestructive: Bool { return false }
    
    // disabled
    var isDisabled: Bool { return false }
}
