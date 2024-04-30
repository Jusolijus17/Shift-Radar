//
//  ReviewOfferModalViewModel.swift
//  Shift Radar
//
//  Created by Justin Lefrançois on 2024-04-06.
//

import Foundation
import UIKit
import FirebaseFunctions

class ReviewPickupModalViewModel: ObservableObject {
    @Published var openBrowser: Bool = false
    
    var browserURL: URL = URL(string: "https://ac.sabrestaffconnect.com/dashboard")!
    
    private var functions = Functions.functions()
    
    func acceptOffer() {
        // Cloud function to change offer status
        openBrowser = true
        let data = ["offerId": "TsMg53lSYSjSSxOM8du9", "responseType": "deal"] // Ajuste cela selon les besoins de ta fonction
        
        // Appeler la fonction Cloud pour accepter l'offre
        functions.httpsCallable("respondToOffer").call(data) { result, error in
            if let error = error {
                print("Error calling function: \(error.localizedDescription)")
            } else if let resultData = result?.data as? [String: Any] {
                print("Offer accepted successfully: \(resultData)")
                DispatchQueue.main.async {
                    self.openBrowser = true
                }
            }
        }
    }
    
    func declineOffer() {
        // Cloud function to change offer status
    }
}
