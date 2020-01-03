//
//  SettingsItemSection.swift
//  Walkie Talkie
//
//  Created by Sebastien Menozzi on 01/01/2020.
//  Copyright © 2020 Sebastien Menozzi. All rights reserved.
//

import Foundation

protocol SettingsItemSection: CustomStringConvertible {
    
    // info
    var icon: String { get }
    var description: String { get }
    
    // value
    var value: String { get }
    var hasValue: Bool { get }
    
    // switch
    var switchValue: Bool { get set }
    var hasSwitch: Bool { get }
    
    // picture
    var hasPicture: Bool { get }
    var pictureUrl: String { get set }
    
    // input
    var inputValue: String { get set }
    var placeholder: String { get }
    var hasInput: Bool { get }
    
    // arrow
    var hasArrow: Bool { get }
    
    // destructive
    var isDestructive: Bool { get }
    
    // disabled
    var isDisabled: Bool { get }
    
}
