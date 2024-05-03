//
//  OfferResponse.swift
//  Shift Radar
//
//  Created by Justin Lefrançois on 2024-04-25.
//

import Foundation

struct OfferResponse: Codable {
    var offerId: String
    var status: OfferStatus
    var compensation: Compensation?
}
