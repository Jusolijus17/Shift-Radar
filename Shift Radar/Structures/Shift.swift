//
//  Shift.swift
//  Shift Radar
//
//  Created by Justin Lefrançois on 2023-11-08.
//

import Foundation
import FirebaseFirestoreSwift
import FirebaseAuth

struct Shift: Codable, Hashable, Identifiable {
    @DocumentID var id: String?
    var createdBy: String?
    var offeredDate: Date?
    var start: Date
    var end: Date
    var location: String
    var compensation: Compensation
    var status: ShiftStatus?
    var offersRef: [String]?
    var pendingOffers: Int
    
    enum CodingKeys: String, CodingKey {
        case id, createdBy, offeredDate, start, end, location, compensation, status, offersRef, pendingOffers
    }
    
    init() {
        let calendar = Calendar.current
        let currentDate = Date()
        if let startOfDay = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: currentDate) {
            self.start = startOfDay
            self.end = startOfDay
        } else {
            self.start = currentDate
            self.end = currentDate
        }
        self.location = "NO_SELECTION"
        self.compensation = Compensation(type: .give)
        self.pendingOffers = 0
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(start, forKey: .start)
        try container.encode(end, forKey: .end)
        try container.encode(location, forKey: .location)
        try container.encode(compensation, forKey: .compensation)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        _id = try container.decode(DocumentID<String>.self, forKey: .id)
        createdBy = try? container.decode(String.self, forKey: .createdBy)
        offeredDate = try? container.decode(Date.self, forKey: .offeredDate)
        start = try container.decode(Date.self, forKey: .start)
        end = try container.decode(Date.self, forKey: .end)
        location = try container.decode(String.self, forKey: .location)
        compensation = try container.decode(Compensation.self, forKey: .compensation)
        offersRef = try? container.decode([String].self, forKey: .offersRef)
        status = try? container.decode(ShiftStatus.self, forKey: .status)
        pendingOffers = try container.decodeIfPresent(Int.self, forKey: .pendingOffers) ?? offersRef?.count ?? 0
    }
}

enum ShiftErrorType {
    case date
    case duration
    case location
    case availabilities
    case saving
}

enum ShiftStatus: Codable {
    case available
    case accepted
    case past
}
