//
//  Offer.swift
//  Shift Radar
//
//  Created by Justin Lefrançois on 2023-12-25.
//

import Foundation
import FirebaseFirestoreSwift

struct Offer: Codable, Hashable, Identifiable {
    @DocumentID var id: String?
    var shiftId: String
    var from: String?
    var date: Date
    var status: OfferStatus
    var compensation: Compensation?
    
    enum CodingKeys: String, CodingKey {
        case id, shiftId, from, date, status, responseType, compensation
    }
    
    init(shiftId: String, compensation: Compensation? = nil) {
        self.shiftId = shiftId
        self.date = Date()
        self.status = .pending
        self.compensation = compensation
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(shiftId, forKey: .shiftId)
        try container.encode(compensation, forKey: .compensation)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        _id = try container.decode(DocumentID<String>.self, forKey: .id)
        shiftId = try container.decode(String.self, forKey: .shiftId)
        from = try container.decode(String.self, forKey: .from)
        date = try container.decode(Date.self, forKey: .date)
        status = try container.decode(OfferStatus.self, forKey: .status)
        compensation = try? container.decode(Compensation.self, forKey: .compensation)
    }
}

enum OfferStatus: String, Codable, CaseIterable {
    case pending
    case accepted
    case declined
    case counterOffer
}
