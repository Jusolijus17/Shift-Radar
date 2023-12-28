//
//  OfferShiftViewModel.swift
//  Shift Radar
//
//  Created by Justin Lefrançois on 2023-11-03.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseFunctions
import FirebaseAuth
import Foundation

class OfferShiftViewModel: ObservableObject {
    @Published var isLoadingShifts: Bool = false
    @Published var confirmOffer: Bool = false
    
    // Gestion des Shifts et Écouteurs
    @Published var selectedShift: Shift = Shift()
    @Published var isEditingShift: Bool = false
    @Published var offeredShifts: [Shift] = []
    @Published var shiftOffers: [Offer] = []
    private var shiftsListener: ListenerRegistration?
    
    // Gestion des Modals et de l'Interface Utilisateur
    @Published var showEditModal: Bool = false
    @Published var showReviewModal: Bool = false
    
    // Gestion des erreurs
    @Published var error: ErrorAlert?
    @Published var showAlert: Bool = false
    
    init() {
        createShiftsObserver()
    }
    
    deinit {
        stopListeningToOfferedShifts()
    }
    
    func prepareNewShift() {
        selectedShift = Shift()
        isEditingShift = false
    }
    
    func selectShiftForEditing(_ shift: Shift) {
        selectedShift = shift
        isEditingShift = true
        showEditModal = true
    }
    
    func selectShiftForReview(_ shift: Shift) {
        selectedShift = shift
        showReviewModal = true
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
    
    private func stopListeningToOfferedShifts() {
        shiftsListener?.remove()
        shiftsListener = nil
    }
    
    // MARK: - Firestore functions
    
    private func createShiftsObserver() {
        guard let userUID = Auth.auth().currentUser?.uid else {
            print("User must be logged in to fetch offered shifts.")
            return
        }
        
        isLoadingShifts = true
        
        let db = Firestore.firestore()
        let userShiftsRef = db.collection("users").document(userUID).collection("shifts").document("offered")

        shiftsListener = userShiftsRef.addSnapshotListener { [weak self] (documentSnapshot, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("Error listening for offered shifts updates: \(error)")
                isLoadingShifts = false
                return
            }

            guard let documentSnapshot = documentSnapshot, documentSnapshot.exists,
                  let refs = documentSnapshot.data()?["refs"] as? [String] else {
                print("Document does not exist or 'refs' field is missing.")
                isLoadingShifts = false
                return
            }

            var fetchedShifts: [Shift] = []
            let group = DispatchGroup()

            for ref in refs {
                group.enter()
                let shiftRef = db.collection("shifts").document(ref)
                shiftRef.getDocument { (shiftDoc, err) in
                    defer { group.leave() }
                    if let err = err {
                        print("Error fetching shift: \(err)")
                    } else if let shiftDoc = shiftDoc, shiftDoc.exists {
                        do {
                            let shift = try shiftDoc.data(as: Shift.self)
                            fetchedShifts.append(shift)
                        } catch {
                            print("Error decoding shift: \(error)")
                        }
                    }
                }
            }

            // Wait for all fetches to complete
            group.notify(queue: .main) {
                self.offeredShifts = fetchedShifts
                self.isLoadingShifts = false
            }
        }
    }
    
    func deleteShift(_ shift: Shift) {
        guard let shiftId = shift.id else {
            print("No shiftId, cannot delete shift.")
            self.error = ErrorAlert(title: "Error deleting shift", message: "No shift ID")
            self.showAlert = true
            return
        }
        
        guard let index = self.offeredShifts.firstIndex(where: { $0.id == shiftId }) else {
            print("Shift not found in offeredShifts")
            return
        }
        let removedShift = self.offeredShifts.remove(at: index)
        
        let functions = Functions.functions()
        
        functions.httpsCallable("deleteShift").call(["shiftId": shiftId]) { [weak self] result, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error calling deleteShift function: \(error)")
                self.error = ErrorAlert(title: "Error deleting shift", message: "Please try again.")
                self.showAlert = true
                self.offeredShifts.insert(removedShift, at: index)
            } else {
                print("Shift successfully deleted")
            }
        }
    }
    
    func getOffers(completion: @escaping ([Offer]?, Error?) -> Void) {
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
    
    func refreshShifts() async {
        guard let userUID = Auth.auth().currentUser?.uid else {
            print("User must be logged in to fetch offered shifts.")
            return
        }

        let db = Firestore.firestore()
        let userShiftsRef = db.collection("users").document(userUID).collection("shifts").document("offered")

        await withCheckedContinuation { continuation in
            userShiftsRef.getDocument { [weak self] (documentSnapshot, error) in
                guard let self = self else {
                    continuation.resume()
                    return
                }

                if let error = error {
                    print("Error listening for offered shifts updates: \(error)")
                    continuation.resume()
                    return
                }

                guard let documentSnapshot = documentSnapshot, documentSnapshot.exists,
                      let refs = documentSnapshot.data()?["refs"] as? [String] else {
                    print("Document does not exist or 'refs' field is missing.")
                    continuation.resume()
                    return
                }

                var fetchedShifts: [Shift] = []
                let group = DispatchGroup()

                for ref in refs {
                    group.enter()
                    let shiftRef = db.collection("shifts").document(ref)
                    shiftRef.getDocument { (shiftDoc, err) in
                        defer { group.leave() }
                        if let err = err {
                            print("Error fetching shift: \(err)")
                        } else if let shiftDoc = shiftDoc, shiftDoc.exists {
                            do {
                                let shift = try shiftDoc.data(as: Shift.self)
                                fetchedShifts.append(shift)
                            } catch {
                                print("Error decoding shift: \(error)")
                            }
                        }
                    }
                }

                group.notify(queue: .main) {
                    self.offeredShifts = fetchedShifts
                    continuation.resume()
                }
            }
        }
    }
}

