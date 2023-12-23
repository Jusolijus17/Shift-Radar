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
    var start: Date
    var end: Date
    var location: String
    var compensationType: CompensationType
    var moneyCompensation: Double
    var availabilities: [Availability]
    
    init() {
        let calendar = Calendar.current
        let currentDate = Date()
        self.offeredDate = Date()
        if let startOfDay = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: currentDate) {
            self.start = startOfDay
            self.end = startOfDay
        } else {
            self.start = currentDate
            self.end = currentDate
        }
        self.location = ""
        self.compensationType = .give
        self.moneyCompensation = 0
        self.availabilities = []
    }
}

extension Shift {
    func toDictionary() -> [String: Any]? {
        var dict: [String: Any] = [:]
        
        // Convertir les propriétés simples
        dict["offeredDate"] = offeredDate.timeIntervalSince1970
        dict["start"] = start.timeIntervalSince1970
        dict["end"] = end.timeIntervalSince1970
        dict["location"] = location
        dict["compensationType"] = compensationType.rawValue // Assurez-vous que `compensationType` est convertible en un format approprié
        dict["moneyCompensation"] = moneyCompensation

        // Convertir les 'availabilities'
        let availabilitiesArray = availabilities.map { availability -> [String: Any] in
            return [
                "date": availability.date.timeIntervalSince1970,
                "startTime": availability.startTime.timeIntervalSince1970,
                "endTime": availability.endTime.timeIntervalSince1970
            ]
        }
        dict["availabilities"] = availabilitiesArray

        return dict
    }
}

enum ShiftErrorType {
    case date
    case duration
    case location
    case availabilities
    case saving
}
