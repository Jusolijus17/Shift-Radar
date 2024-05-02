//
//  ReviewOfferModalViewModel.swift
//  Shift Radar
//
//  Created by Justin Lefrançois on 2024-04-06.
//

import Foundation
import UIKit
import FirebaseFunctions
import FirebaseFirestore

class ReviewPickupModalViewModel: ObservableObject {
    @Published var userDatas: [String: UserData] = [:]
    @Published var openBrowser: Bool = false
    
    var browserURL: URL = URL(string: "https://ac.sabrestaffconnect.com/dashboard")!
    
    private var functions = Functions.functions()
    
    func loadUserDatas(offers: [Offer]) {
        let userIds = Set(offers.compactMap { $0.from })
        for userId in userIds {
            fetchUserData(fromId: userId) { userData in
                if let userData = userData {
                    DispatchQueue.main.async {
                        self.userDatas[userId] = userData
                    }
                }
            }
        }
    }
    
    func acceptOffer(offer: Offer) {
        guard let offerId = offer.id else {
            print("Offer id not found")
            return
        }
        
        openBrowser = true
        
        let response = OfferResponse(offerId: offerId, status: .accepted)
        respondToOffer(response) { _ in
            
        }
    }
    
    func declineOffer(offer: Offer) {
        guard let offerId = offer.id else {
            print("Offer id not found")
            return
        }
        let response = OfferResponse(offerId: offerId, status: .declined)
        print("Response : ", response)
        respondToOffer(response) { _ in
            
        }
    }
    
    private func respondToOffer(_ response: OfferResponse, completion: @escaping (Bool) -> Void) {
        let responseData = response.toDictionary()
        functions.httpsCallable("respondToOffer").call(["response": responseData]) { result, error in
            if let error = error {
                print("Error calling function: \(error.localizedDescription)")
                completion(false)
            } else if let resultData = result?.data as? [String: Any] {
                print("Offer accepted successfully: \(resultData)")
                completion(true)
            }
        }
    }
    
    private func fetchUserData(fromId: String, completion: @escaping (UserData?) -> Void) {
        let userRef = Firestore.firestore().collection("users").document(fromId)
        userRef.getDocument { (document, error) in
            if let document = document, document.exists, let userData = try? document.data(as: UserData.self) {
                completion(userData)
            } else {
                print("Document does not exist or failed to decode:", error?.localizedDescription ?? "Unknown error")
                completion(nil)
            }
        }
    }
}
