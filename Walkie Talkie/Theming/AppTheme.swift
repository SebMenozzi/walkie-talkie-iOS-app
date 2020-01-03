//
//  AppTheme.swift
//  Walkie Talkie
//
//  Created by Sebastien Menozzi on 01/01/2020.
//  Copyright © 2020 Sebastien Menozzi. All rights reserved.
//

import UIKit

struct AppTheme {
    var backgroundColor: UIColor
    var cellbackgroundColor: UIColor
    var separatorColor: UIColor
}

extension AppTheme {

    static let basic = AppTheme(
        backgroundColor: .black,
        cellbackgroundColor: UIColor(r: 20, g: 20, b: 20),
        separatorColor: UIColor(white: 1.0, alpha: 0.1)
    )
    
    static let christmas = AppTheme(
        backgroundColor: UIColor(r: 200, g: 31, b: 43),
        cellbackgroundColor: UIColor(white: 0, alpha: 0.2),
        separatorColor: UIColor(white: 0, alpha: 0.1)
    )
    
    static let purple = AppTheme(
        backgroundColor: UIColor(r: 138, g: 43, b: 226),
        cellbackgroundColor: UIColor(white: 0, alpha: 0.2),
        separatorColor: UIColor(white: 0, alpha: 0.1)
    )
    
    static let emerald = AppTheme(
        backgroundColor: UIColor(r: 0, g: 167, b: 141),
        cellbackgroundColor: UIColor(white: 0, alpha: 0.2),
        separatorColor: UIColor(white: 0, alpha: 0.1)
    )
    
    static let pink = AppTheme(
        backgroundColor: UIColor(r: 230, g: 45, b: 155),
        cellbackgroundColor: UIColor(white: 0, alpha: 0.2),
        separatorColor: UIColor(white: 0, alpha: 0.1)
    )
}
