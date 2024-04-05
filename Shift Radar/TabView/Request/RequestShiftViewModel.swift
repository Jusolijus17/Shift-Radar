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

class RequestShiftViewModel: ObservableObject {
    @Published var isLoadingShifts: Bool = false
    @Published var userShiftsWithOffers: [Shift] = []

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


}
