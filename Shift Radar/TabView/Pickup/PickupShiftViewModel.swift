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
    @Published var filteredShifts: [Shift] = []
    
    init() {
        createAllShiftsObserver()
    }
    
    deinit {
        stopListeningToOfferedShifts()
    }
    
    private func createAllShiftsObserver() {
        isLoadingShifts = true
        
        let db = Firestore.firestore()
        let shiftsRef = db.collection("shifts")
        let userUid = Auth.auth().currentUser?.uid
        let currentTimestamp = Timestamp(date: Date())
        
        shiftsListener = shiftsRef
            .whereField("start", isGreaterThan: currentTimestamp)
            .addSnapshotListener { [weak self] (querySnapshot, error) in
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
                        if shift.createdBy != userUid {
                            fetchedShifts.append(shift)
                        }
                    } catch {
                        print("Error decoding shift: \(error)")
                    }
                }
                
                let futureShifts = fetchedShifts.filter { $0.start > Date() }
                self.offeredShifts = futureShifts
                self.isLoadingShifts = false
            }
    }
    
    func searchShifts(startDate: Date?, endDate: Date?) {
        guard let startDate = startDate, let endDate = endDate else {
            self.clearSearch()
            return
        }
        
        let db = Firestore.firestore()
        let shiftsRef = db.collection("shifts")
        
        var dayAfterEndDate = Calendar.current.startOfDay(for: endDate)
        dayAfterEndDate = Calendar.current.date(byAdding: .day, value: 1, to: dayAfterEndDate)!
        
        let startOfDay = Calendar.current.startOfDay(for: startDate)
        
        guard let userUid = Auth.auth().currentUser?.uid else { return }
        
        shiftsRef.whereField("end", isLessThanOrEqualTo: Timestamp(date: dayAfterEndDate))
            .getDocuments { [weak self] querySnapshot, error in
                if let error = error {
                    print("Error getting documents: \(error)")
                    return
                }
                
                guard let querySnapshot = querySnapshot else {
                    print("Error: querySnapshot est nil")
                    return
                }
                
                let shifts = querySnapshot.documents.compactMap { document -> Shift? in
                    guard let shift = try? document.data(as: Shift.self),
                          shift.start >= startOfDay,
                          shift.end < dayAfterEndDate,
                          shift.createdBy != userUid else { return nil }
                    return shift
                }
                
                self?.filteredShifts = shifts
            }
    }
    
    private func clearSearch() {
        self.filteredShifts = []
    }
    
    private func stopListeningToOfferedShifts() {
        shiftsListener?.remove()
        shiftsListener = nil
    }
}
