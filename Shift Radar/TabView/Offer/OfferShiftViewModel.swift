//
//  OfferShiftViewModel.swift
//  Shift Radar
//
//  Created by Justin Lefrançois on 2023-11-03.
//

import SwiftUI
import FirebaseFirestore

enum CompensationType {
    case give
    case sell
    case trade
}

extension CompensationType {
    func stringValue() -> String {
        switch self {
        case .give:
            return "give"
        case .sell:
            return "sell"
        case .trade:
            return "trade"
        }
    }
}

struct Availability {
    var date: Date
    var startTime: Date
    var endTime: Date
}

struct Shift {
    var date: Date = Date()
    var startTime: Date = Date()
    var endTime: Date = Date()
    var location: String = "Location1"
    // Compensation
    var compensationType: CompensationType = .give
    var moneyCompensation: Double = 0
    var availabilities: [Availability] = []
}

class OfferShiftViewModel: ObservableObject {
    @Published var isEmpty: Bool = true
    @Published var error: String?
    @Published var isSaving: Bool = false
    
    // Modal
    @Published var showModal: Bool = true
    
    // Shift data
    @Published var shiftData: Shift
    
    let locations = ["Location1", "Location2", "Location3"]
    
    init() {
        let calendar = Calendar.current
        let currentDate = Date()
        var newShift = Shift()
        
        if let startOfDay = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: currentDate) {
            newShift.startTime = startOfDay
            newShift.endTime = calendar.date(byAdding: .hour, value: 0, to: startOfDay) ?? startOfDay
        }
        
        self.shiftData = newShift
    }
    
    func hoursBetweenShiftTimes() -> Int {
        let calendar = Calendar.current
        var hours = calendar.dateComponents([.hour], from: shiftData.startTime, to: shiftData.endTime).hour ?? 0
        if hours < 0 {
            hours += 24
        }
        
        return hours
    }
    
    func changeCompensationType(newValue: CompensationType) {
        shiftData.compensationType = newValue
    }
    
    func saveShift(dismissAction: @escaping () -> Void) {
        guard shiftIsValid() else { return }
        isSaving = true
        
        let shiftDict: [String: Any] = [
            "date": Timestamp(date: shiftData.date),
            "startTime": Timestamp(date: shiftData.startTime),
            "endTime": Timestamp(date: shiftData.endTime),
            "location": shiftData.location,
            "compensationType": String(describing: shiftData.compensationType),
            "moneyCompensation": shiftData.moneyCompensation,
            "availabilities": shiftData.availabilities.map { availability in
                return [
                    "date": Timestamp(date: availability.date),
                    "startTime": Timestamp(date: availability.startTime),
                    "endTime": Timestamp(date: availability.endTime)
                ]
            }
        ]

        // Référence à la base de données Firestore
        let db = Firestore.firestore()

        // Ajouter un nouveau document avec un ID généré automatiquement
        var ref: DocumentReference? = nil
        ref = db.collection("shifts").addDocument(data: shiftDict) { error in
            if let err = error {
                self.error = "Error adding document: \(err)"
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
                self.isSaving = false
                dismissAction()
            }
        }
    }
    
    func shiftIsValid() -> Bool {
        guard hoursBetweenShiftTimes() != 0 else {
            error = "Your shift must be at least 1h."
            return false
        }
        guard shiftData.location != "" else {
            error = "Please select your location."
            return false
        }
        return true
    }

}

