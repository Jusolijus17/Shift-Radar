//
//  Shift.swift
//  Shift Radar
//
//  Created by Justin Lefrançois on 2023-11-08.
//

import Foundation
import FirebaseFirestoreSwift

enum CompensationType: String, Codable {
    case give
    case sell
    case trade
}

struct Availability: Codable, Hashable {
    var date: Date
    var startTime: Date
    var endTime: Date
}

struct Shift: Codable, Hashable {
    @DocumentID var id: String?
    var offeredDate: Date
    var startTime: Date
    var endTime: Date
    var location: String
    var compensationType: CompensationType
    var moneyCompensation: Double
    var availabilities: [Availability]
    
    init() {
        self.offeredDate = Date()
        self.startTime = Date()
        self.endTime = Date()
        self.location = ""
        self.compensationType = .give
        self.moneyCompensation = 0
        self.availabilities = []
    }
}

enum ShiftErrorType {
    case date
    case duration
    case location
    case availabilities
    case saving
}
