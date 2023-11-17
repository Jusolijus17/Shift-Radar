//
//  PickupShiftViewModel.swift
//  Shift Radar
//
//  Created by Justin Lefrançois on 2023-11-16.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

class PickupShiftViewModel: ObservableObject {
    @Published var isLoadingShifts: Bool = false
    
    private var shiftsListener: ListenerRegistration?
    @Published var offeredShifts: [Shift] = []
    
    init() {
        createAllShiftsObserver()
    }
    
    private func createAllShiftsObserver() {
        isLoadingShifts = true

        let db = Firestore.firestore()
        let shiftsRef = db.collection("shifts")

        shiftsListener = shiftsRef.addSnapshotListener { [weak self] (querySnapshot, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("Error listening for shifts updates: \(error)")
                self.isLoadingShifts = false
                return
            }

            guard let querySnapshot = querySnapshot else {
                print("Error fetching snapshots: \(error?.localizedDescription ?? "No error")")
                self.isLoadingShifts = false
                return
            }

            var fetchedShifts: [Shift] = []
            
            for document in querySnapshot.documents {
                do {
                    let shift = try document.data(as: Shift.self)
                    fetchedShifts.append(shift)
                } catch {
                    print("Error decoding shift: \(error)")
                }
            }

            self.offeredShifts = fetchedShifts
            self.isLoadingShifts = false
        }
    }

}
