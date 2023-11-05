//
//  OfferShiftViewModel.swift
//  Shift Radar
//
//  Created by Justin Lefrançois on 2023-11-03.
//

import SwiftUI

struct Availability {
    var date: Date
    var startTime: Date
    var endTime: Date
}

struct Shift {
    var date: Date = Date()
    var startTime: Date = Date()
    var endTime: Date = Date()
    var location: String = ""
    // Compensation
    var moneyCompensation: Double = 0
    var availabilities: [Availability] = []
}

class OfferShiftViewModel: ObservableObject {
    @Published var isEmpty: Bool = true
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

}

