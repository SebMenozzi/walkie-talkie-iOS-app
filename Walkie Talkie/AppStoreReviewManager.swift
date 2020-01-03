//
//  AppStoreReviewManager.swift
//  Walkie Talkie
//
//  Created by Sebastien Menozzi on 01/01/2020.
//  Copyright © 2020 Sebastien Menozzi. All rights reserved.
//

import Foundation
import StoreKit

class AppStoreReviewManager {
    
    static let instance = AppStoreReviewManager()
    
    private func getRunCounts() -> Int {
        if let runs = UserDefaults.standard.value(forKey: "RATE_NUMBER_OF_RUNS") as? Int{
            return runs
        }
        return 0
    }
    
    private func canShowReview() -> Bool{
        let runs = getRunCounts()
        return runs == 10 || runs == 50 || runs % 100 == 0
    }
    
    func incrementAppRuns() { // called from appdelegate didfinishLaunchingWithOptions:
        let runs = getRunCounts() + 1
        UserDefaults.standard.set(runs, forKey: "RATE_NUMBER_OF_RUNS")
        UserDefaults.standard.synchronize()
    }
    
    func showReview(){
        if #available(iOS 10.3, *) {
            if canShowReview() {
                SKStoreReviewController.requestReview()
            }
        }
    }
    
}
