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
    
    @Published var showAlert: Bool = false
    @Published var error: String = ""
    
    // Gestion des Shifts et Écouteurs
    @Published var selectedShift: Shift = Shift()
    @Published var isEditingShift: Bool = false
    @Published var offeredShifts: [Shift] = []
    private var shiftsListener: ListenerRegistration?
    
    // Gestion des Modals et de l'Interface Utilisateur
    @Published var showModal: Bool = false
    
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
        showModal = true
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
            self.showError(message: "Error deleting shift. No shift ID")
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
                self.showError(message: "Error deleting shift. Please try again.")
                self.offeredShifts.insert(removedShift, at: index)
            } else {
                print("Shift successfully deleted")
            }
        }
    }
    
    private func showError(message: String) {
        self.showAlert = true
        self.error = message
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

