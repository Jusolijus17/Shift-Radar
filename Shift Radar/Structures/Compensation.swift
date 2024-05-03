//
//  Compensation.swift
//  Shift Radar
//
//  Created by Justin Lefrançois on 2024-04-25.
//

import Foundation

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

enum CompensationType: String, Codable, Hashable, CaseIterable {
    case give
    case sell
    case trade
}

struct Availability: Codable, Hashable {
    var date: Date
    var startTime: Date
    var endTime: Date
}
