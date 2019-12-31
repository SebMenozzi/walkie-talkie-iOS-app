//
//  Constants.swift
//  Walkie Talkie
//
//  Created by Sebastien Menozzi on 28/12/2019.
//  Copyright © 2019 Sebastien Menozzi. All rights reserved.
//

import AVFoundation

struct Constants {
    
    static let BUFFER_SIZE = 1024
    static let HOST = "51.77.137.209"
    static let PORT = 2712
    static let SETTINGS = [
        AVFormatIDKey: kAudioFormatLinearPCM,
        AVLinearPCMBitDepthKey: 16,
        AVLinearPCMIsFloatKey: true,
        AVSampleRateKey: Float64(16000),
        AVNumberOfChannelsKey: 1
    ] as [String : Any]
    static let FORMAT = AVAudioFormat(settings: SETTINGS)
    static let pixelInCentimetre: CGFloat = 80
    
    static let labelWidth: CGFloat = 100
    static let labelHeight: CGFloat = 20
    static let labelMarginTop: CGFloat = 5
    static let rulerHeight: CGFloat = 100
    
}
