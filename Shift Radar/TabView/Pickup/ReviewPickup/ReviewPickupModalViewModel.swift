//
//  ReviewOfferModalViewModel.swift
//  Shift Radar
//
//  Created by Justin Lefrançois on 2024-04-06.
//

import Foundation
import UIKit

class ReviewPickupModalViewModel: ObservableObject {
    @Published var openBrowser: Bool = false
    
    var browserURL: URL = URL(string: "https://ac.sabrestaffconnect.com/dashboard")!
    
    func acceptOffer() {
        openBrowser = true
    }
    
    func declineOffer() {
        
    }
}
