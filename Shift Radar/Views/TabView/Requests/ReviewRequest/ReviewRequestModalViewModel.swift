//
//  ReviewOfferModalViewModel.swift
//  Shift Radar
//
//  Created by Justin Lefrançois on 2024-04-06.
//

import Foundation
import UIKit
import SwiftUI
import FirebaseFunctions
import FirebaseFirestore

class ReviewRequestModalViewModel: ObservableObject {
    @Published var offers: [Offer] = []
    @Published var userDatas: [String: UserData] = [:]
    @Published var openBrowser: Bool = false
    @Published var declineLoading: Bool = false
    @Published var acceptLoading: Bool = false
    @Binding var shouldReloadRequests: Bool
    
    var browserURL: URL = URL(string: "https://ac.sabrestaffconnect.com/dashboard")!
    
    init(shouldReloadRequests: Binding<Bool>) {
        _shouldReloadRequests = shouldReloadRequests
    }
    
    private var functions = Functions.functions()
    
    func loadUserDatas() {
        let userIds = Set(self.offers.compactMap { $0.from })
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
    
    func acceptOffer(at index: Int) {
        self.acceptLoading = true
        guard offers.count > index, let offerId = offers[index].id else {
            print("Offer id not found")
            self.acceptLoading = false
            return
        }
        
        openBrowser = true
        
        let response = OfferResponse(offerId: offerId, status: .accepted)
        respondToOffer(response) { success, result  in
            self.acceptLoading = false
            if success, let result {
                print("Offer accepted successfully: \(result)")
                self.shouldReloadRequests = true
                DispatchQueue.main.async {
                    self.offers[index].status = .accepted
                }
            }
        }
    }
    
    func declineOffer(at index: Int) {
        self.declineLoading = true
        guard offers.count > index, let offerId = offers[index].id else {
            print("Offer id not found")
            self.declineLoading = false
            return
        }
        let response = OfferResponse(offerId: offerId, status: .declined)
        print("Response : ", response)
        respondToOffer(response) { success, result in
            self.declineLoading = false
            if success, let result {
                print("Offer declined successfully: \(result)")
                self.shouldReloadRequests = true
                DispatchQueue.main.async {
                    self.offers[index].status = .declined
                }
            }
        }
    }
    
    private func respondToOffer(_ response: OfferResponse, completion: @escaping (Bool, [String: Any]?) -> Void) {
        let responseData = response.toDictionary()
        functions.httpsCallable("respondToOffer").call(["response": responseData]) { result, error in
            if let error = error {
                print("Error calling function: \(error.localizedDescription)")
                completion(false, nil)
            } else if let resultData = result?.data as? [String: Any] {
                completion(true, resultData)
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
