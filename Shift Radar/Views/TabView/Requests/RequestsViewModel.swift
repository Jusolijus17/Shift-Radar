//
//  RequestShiftViewModel.swift
//  Shift Radar
//
//  Created by Justin Lefrançois on 2024-04-04.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth

class RequestsViewModel: ObservableObject {
    @Published var isLoadingShifts: Bool = false
    @Published var userShiftsWithOffers: [Shift] = []
    
    @Published var selectedShift: Shift = Shift()
    @Published var showReviewModal: Bool = false
    @Published var shiftOffers: [Offer] = []
    
    @Published var error: ErrorAlert?
    @Published var showAlert: Bool = false

    init() {
        loadUserShiftsWithOffers()
    }

    func loadUserShiftsWithOffers() {
        guard let userUID = Auth.auth().currentUser?.uid else {
            print("User must be logged in to fetch their shifts.")
            return
        }

        isLoadingShifts = true
        let db = Firestore.firestore()
        db.collection("shifts")
            .whereField("createdBy", isEqualTo: userUID)
            .getDocuments { [weak self] (querySnapshot, error) in
                guard let self = self else { return }
                self.isLoadingShifts = false

                if let error = error {
                    print("Error fetching user shifts: \(error)")
                    return
                }

                self.userShiftsWithOffers = querySnapshot?.documents.compactMap { document -> Shift? in
                    guard let shift = try? document.data(as: Shift.self) else { return nil }
                    return shift.offersRef != nil && !(shift.offersRef!.isEmpty) ? shift : nil
                } ?? []
            }
    }
    
    func reloadDataAsync() async {
        guard let userUID = Auth.auth().currentUser?.uid else {
            print("User must be logged in to fetch their shifts.")
            return
        }

        let db = Firestore.firestore()
        
        await withCheckedContinuation { continuation in
            db.collection("shifts")
                .whereField("createdBy", isEqualTo: userUID)
                .getDocuments { [weak self] (querySnapshot, error) in
                    guard let self = self else {
                        continuation.resume()
                        return
                    }
                    
                    if let error = error {
                        print("Error fetching user shifts: \(error)")
                        self.isLoadingShifts = false
                        continuation.resume()
                        return
                    }

                    var shiftsToLoad: [Shift] = []
                    let group = DispatchGroup()

                    for document in querySnapshot!.documents {
                        guard let shift = try? document.data(as: Shift.self), shift.offersRef != nil && !shift.offersRef!.isEmpty else {
                            continue
                        }
                        group.enter()
                        db.collection("shifts").document(document.documentID).getDocument { (shiftDoc, err) in
                            defer { group.leave() }
                            if let err = err {
                                print("Error fetching shift details: \(err)")
                            } else if let shiftDoc = shiftDoc, shiftDoc.exists, let detailedShift = try? shiftDoc.data(as: Shift.self) {
                                shiftsToLoad.append(detailedShift)
                            }
                        }
                    }

                    group.notify(queue: .main) {
                        self.userShiftsWithOffers = shiftsToLoad
                        continuation.resume()
                    }
                }
        }
    }
    
    func selectShiftForReview(_ shift: Shift) {
        selectedShift = shift
        showReviewModal = true
        self.shiftOffers = []
        getOffers() { [weak self] offers, error in
            DispatchQueue.main.async {
                if let offers = offers {
                    self?.shiftOffers = offers
                } else {
                    self?.error = ErrorAlert(title: "Error loading offer(s)", message: "No valid offers found.")
                    self?.showAlert = true
                    print("Erreur lors du chargement des offres: \(error?.localizedDescription ?? "")")
                }
            }
        }
    }
    
    private func getOffers(completion: @escaping ([Offer]?, Error?) -> Void) {
        guard let offerIds = selectedShift.offersRef, !offerIds.isEmpty else {
            completion(nil, nil) // Pas d'offres à charger
            return
        }

        let offersRef = Firestore.firestore().collection("offers")
        var offers: [Offer] = []
        let dispatchGroup = DispatchGroup()

        for offerId in offerIds {
            dispatchGroup.enter()
            offersRef.document(offerId).getDocument { (document, error) in
                defer {
                    dispatchGroup.leave()
                }

                if let error = error {
                    print("Erreur lors du chargement de l'offre \(offerId): \(error)")
                    return
                }

                if let document = document, document.exists, let offer = try? document.data(as: Offer.self) {
                    offers.append(offer)
                } else {
                    print("Aucune offre valide trouvée pour l'ID \(offerId)")
                }
            }
        }

        dispatchGroup.notify(queue: .main) {
            if offers.isEmpty {
                completion(nil, NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Aucune offre trouvée"]))
            } else {
                completion(offers, nil)
            }
        }
    }


}
