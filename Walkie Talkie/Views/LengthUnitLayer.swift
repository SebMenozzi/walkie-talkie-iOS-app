//
//  LengthUnitLayer.swift
//  Walkie Talkie
//
//  Created by Sebastien Menozzi on 30/12/2019.
//  Copyright © 2019 Sebastien Menozzi. All rights reserved.
//

import UIKit

class LengthUnitLayer: CALayer {

    // MARK: - Properties
    
    // how many pixels for width of a line.
    private let lineWidth: CGFloat
    
    // which color we’ll draw for the ruler.
    private let lineColor: CGColor

    // the length in pixel for one unit
    private var unitWidth: CGFloat = 80

    // the length in pixel between two lines.
    private var spaceBetweenLines: CGFloat {
        return (unitWidth / 10)
    }
    
    // the length in pixel of this layer.
    private var layerWidth: CGFloat {
        return (unitWidth + lineWidth)
    }


    // MARK: - View Life Cycle
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(lineWidth: CGFloat, lineColor: CGColor, height: CGFloat) {
        self.lineWidth = lineWidth
        self.lineColor = lineColor

        super.init()

        frame = .init(x: 0, y: 0, width: layerWidth, height: height)
    }
    
    override func draw(in ctx: CGContext) {
        ctx.setStrokeColor(lineColor)
        ctx.setLineWidth(lineWidth)
        ctx.beginPath()

        for i in 0...10 {
            let x = lineWidth / 2 + CGFloat(i) * spaceBetweenLines

            let y: CGFloat = {
                if (i % 10 == 0) {
                    return bounds.height
                } else if (i % 5 == 0) {
                    return bounds.height * 0.75
                } else {
                    return bounds.height * 0.5
                }
            }()

            ctx.move(to: .init(x: x, y: 0))
            ctx.addLine(to: .init(x: x, y: y))
        }

        ctx.strokePath()
        ctx.flush()
    }
}
