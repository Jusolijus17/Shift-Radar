//
//  Shift.swift
//  Shift Radar
//
//  Created by Justin Lefrançois on 2023-11-08.
//

import Foundation
import FirebaseFirestoreSwift
import FirebaseAuth

struct Offer: Codable, Hashable {
    var id: String
    var date: Date
    var status: OfferStatus
    var from: String
}

enum OfferStatus: String, Codable, CaseIterable {
    case pending = "pending"
    case accepted = "accepted"
    case declined = "declined"
}

enum CompensationType: String, Codable, Hashable, CaseIterable {
    case give = "give"
    case sell = "sell"
    case trade = "trade"
}

struct Availability: Codable, Hashable {
    var date: Date
    var startTime: Date
    var endTime: Date
}

struct Compensation: Codable, Hashable {
    var type: CompensationType
    var amount: Double? // Utilisé uniquement pour .sell
    var availabilities: [Availability]? // Utilisé uniquement pour .trade

    init(type: CompensationType, amount: Double? = nil, availabilities: [Availability]? = nil) {
        self.type = type
        self.amount = amount
        self.availabilities = availabilities
        
        switch self.type {
        case .give:
            return
        case .sell:
            self.amount = amount ?? 0
            self.availabilities = nil
        case .trade:
            self.amount = nil
            self.availabilities = availabilities ?? []
        }
    }
}

struct Shift: Codable, Hashable, Identifiable {
    @DocumentID var id: String?
    var createdBy: String?
    var offeredDate: Date?
    var start: Date
    var end: Date
    var location: String
    var compensation: Compensation
    var offers: [Offer]?
    
    enum CodingKeys: String, CodingKey {
        case id, createdBy, offeredDate, start, end, location, compensation, offers
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
        self.location = "UNKNOWN_LOCATION"
        self.compensation = Compensation(type: .give)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(start, forKey: .start)
        try container.encode(end, forKey: .end)
        try container.encode(location, forKey: .location)
        try container.encode(compensation, forKey: .compensation)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        _id = try container.decode(DocumentID<String>.self, forKey: .id)
        createdBy = try container.decode(String.self, forKey: .createdBy)
        offeredDate = try container.decode(Date.self, forKey: .offeredDate)
        start = try container.decode(Date.self, forKey: .start)
        end = try container.decode(Date.self, forKey: .end)
        location = try container.decode(String.self, forKey: .location)
        compensation = try container.decode(Compensation.self, forKey: .compensation)
        offers = try container.decode([Offer].self, forKey: .offers)
    }
}

extension Shift {
    func toDictionary() -> [String: Any]? {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .secondsSince1970
        
        do {
            let data = try encoder.encode(self)
            let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
            return dictionary
        } catch {
            print("Error converting Shift to dictionary: \(error)")
            return nil
        }
    }
}

enum ShiftErrorType {
    case date
    case duration
    case location
    case availabilities
    case saving
}
