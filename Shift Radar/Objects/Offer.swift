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
    var firstName: String
    var lastName: String
    var date: Date
    var status: OfferStatus
    var responseType: ResponseType
    var compensation: Compensation?
    
    enum CodingKeys: String, CodingKey {
        case id, shiftId, from, firstName, lastName, date, status, responseType, compensation
    }
    
    init(firstName: String, lastName: String, shiftId: String, responseType: ResponseType = .deal, compensation: Compensation? = nil) {
        self.firstName = firstName
        self.lastName = lastName
        self.shiftId = shiftId
        self.date = Date()
        self.status = .pending
        self.responseType = responseType
        self.compensation = compensation
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(shiftId, forKey: .shiftId)
        try container.encode(firstName, forKey: .firstName)
        try container.encode(lastName, forKey: .lastName)
        try container.encode(responseType, forKey: .responseType)
        try container.encode(compensation, forKey: .compensation)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        _id = try container.decode(DocumentID<String>.self, forKey: .id)
        shiftId = try container.decode(String.self, forKey: .shiftId)
        from = try container.decode(String.self, forKey: .from)
        firstName = try container.decode(String.self, forKey: .firstName)
        lastName = try container.decode(String.self, forKey: .lastName)
        date = try container.decode(Date.self, forKey: .date)
        status = try container.decode(OfferStatus.self, forKey: .status)
        responseType = try container.decode(ResponseType.self, forKey: .responseType)
        compensation = try? container.decode(Compensation.self, forKey: .compensation)
    }
}

enum OfferStatus: String, Codable, CaseIterable {
    case pending = "pending"
    case accepted = "accepted"
    case declined = "declined"
}

enum ResponseType: String, Codable, Hashable, CaseIterable {
    case deal = "deal"
    case counterOffer = "counter-offer"
}
