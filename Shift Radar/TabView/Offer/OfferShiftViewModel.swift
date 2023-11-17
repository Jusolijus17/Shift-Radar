//
//  OfferShiftViewModel.swift
//  Shift Radar
//
//  Created by Justin Lefrançois on 2023-11-03.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth
import Foundation

class OfferShiftViewModel: ObservableObject {
    @Published var isLoadingShifts: Bool = false
    @Published var confirmOffer: Bool = false
    
    // Gestion des Shifts et Écouteurs
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

            // Array to hold the fetched shifts
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
    
    private func stopListeningToOfferedShifts() {
        shiftsListener?.remove()
        shiftsListener = nil
    }
    
    func deleteShift(_ id: String?) {
        guard let id = id else { return }
        
        guard let userUID = Auth.auth().currentUser?.uid else {
            print("User must be logged in to delete a shift.")
            return
        }
        
        let db = Firestore.firestore()
        
        // Créez une référence au document shift dans la collection 'shifts'
        let shiftRef = db.collection("shifts").document(id)
        
        // Commencez par supprimer le shift lui-même
        shiftRef.delete { error in
            if let error = error {
                print("Error deleting shift document: \(error)")
            } else {
                print("Shift successfully deleted")
            }
        }
        
        // Ensuite, supprimez la référence de ce shift dans le tableau 'refs' du document 'offered'
        let userShiftsRef = db.collection("users").document(userUID).collection("shifts").document("offered")
        
        // Utilisez FieldValue.arrayRemove pour supprimer l'ID du shift du tableau 'refs'
        userShiftsRef.updateData(["refs": FieldValue.arrayRemove([id])]) { error in
            if let error = error {
                print("Error removing shift reference from user document: \(error)")
            } else {
                print("Shift reference successfully removed from user document")
            }
        }
    }
}

