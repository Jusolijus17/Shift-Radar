//
//  OfferShiftViewModel.swift
//  Shift Radar
//
//  Created by Justin Lefrançois on 2023-11-03.
//

import SwiftUI

import Foundation

class OfferShiftViewModel: ObservableObject {
    @Published var isEmpty: Bool = true
    @Published var showModal: Bool = true
    
    // Shift data
    @Published var startTime: Date
    @Published var endTime: Date
    @Published var location: String = ""
    
    let locations = ["Location1", "Location2", "Location3"]
    
    init() {
        let calendar = Calendar.current
        let currentDate = Date()
        if let startOfDay = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: currentDate) {
            self.startTime = startOfDay
            self.endTime = startOfDay
        } else {
            self.startTime = currentDate
            self.endTime = currentDate
        }
    }
}

