//
//  OfferShiftModel.swift
//  Shift Radar
//
//  Created by Justin Lefrançois on 2023-11-16.
//

import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseDatabase

class OfferShiftModel: ObservableObject {
    @Published var shift: Shift
    
    @Published var shiftErrorType: ShiftErrorType?
    
    @Published var isSaving: Bool = false
    
    @Published var menuOptions: [String] = [] {
        didSet {
            if !menuOptions.isEmpty {
                shift.location = menuOptions[0]
            }
        }
    }
    @Published var filters: [String] = ["RAMP", "FLOATER", "OTHER"]
    @Published var optionFilter: String = ""
    var filteredMenuOptions: [String] {
        if optionFilter == "OTHER" {
            return menuOptions.filter { option in
                filters.filter { $0 != "OTHER" }.allSatisfy { !option.contains($0) }
            }
        } else {
            return menuOptions.filter { $0.contains(optionFilter) || optionFilter.isEmpty }
        }
    }
    
    @Published var confirmOffer: Bool = false
    
    private var lastOptionsUpdate: TimeInterval {
        get { UserDefaults.standard.double(forKey: "lastOptionsUpdate") }
        set { UserDefaults.standard.set(newValue, forKey: "lastOptionsUpdate") }
    }
    
    init() {
        let calendar = Calendar.current
        let currentDate = Date()
        var newShift = Shift()
        
        if let startOfDay = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: currentDate) {
            newShift.startTime = startOfDay
            newShift.endTime = calendar.date(byAdding: .hour, value: 0, to: startOfDay) ?? startOfDay
        }
        
        self.shift = newShift
        loadMenuOptionsIfNeeded()
    }
    
    func applyOptionFilter(_ filter: String?) {
        optionFilter = filter ?? ""
        shift.location = filteredMenuOptions[0]
    }
    
    func hoursBetweenShiftTimes() -> Int {
        let calendar = Calendar.current
        var hours = calendar.dateComponents([.hour], from: shift.startTime, to: shift.endTime).hour ?? 0
        if hours < 0 {
            hours += 24
        }
        
        return hours
    }
    
    func refreshEndTime(_ oldValue: Date, _ newValue: Date) {
        let calendar = Calendar.current
        
        let currentComponents = calendar.dateComponents([.year, .month, .day], from: oldValue)
        let newComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: newValue)
        
        let endTimeComponents = calendar.dateComponents([.hour, .minute], from: shift.endTime)
        
        if currentComponents.year != newComponents.year ||
            currentComponents.month != newComponents.month ||
            currentComponents.day != newComponents.day {
            
            var newDate = DateComponents()
            newDate.year = newComponents.year
            newDate.month = newComponents.month
            
            // Déballez les heures et les minutes de manière sécurisée.
            if let newHour = newComponents.hour, let newMinute = newComponents.minute,
               let endHour = endTimeComponents.hour, let endMinute = endTimeComponents.minute {
               
                // Vérifiez si endTime est techniquement le lendemain.
                if endHour < newHour || (endHour == newHour && endMinute < newMinute) {
                    // endTime est le lendemain, ajoutez un jour à newComponents.day.
                    if let nextDay = calendar.date(byAdding: .day, value: 1, to: calendar.date(from: newComponents)!) {
                        let nextDayComponents = calendar.dateComponents([.day], from: nextDay)
                        newDate.day = nextDayComponents.day
                    }
                } else {
                    // Si ce n'est pas le lendemain, gardez le même jour.
                    newDate.day = newComponents.day
                }
                
                newDate.hour = endHour
                newDate.minute = endMinute
                
                // Créez la nouvelle date de fin et affectez-la.
                if let newEndTime = calendar.date(from: newDate) {
                    shift.endTime = newEndTime
                }
            }
        }
    }
    
    func changeCompensationType(newValue: CompensationType) {
        switch newValue {
        case .give:
            shift.moneyCompensation = 0
        case .sell:
            shift.availabilities = []
        case .trade:
            shift.moneyCompensation = 0
        }
        
        withAnimation(.easeIn(duration: 0.2)) {
            shift.compensationType = newValue
        }
    }
    
    func saveShift(dismissAction: @escaping () -> Void) {
        guard shiftIsValid() else { return }
        isSaving = true
        
        guard let userUID = Auth.auth().currentUser?.uid else {
            print( "User must be logged in to save a shift.")
            self.isSaving = false
            return
        }
        
        // Référence à la base de données Firestore
        let db = Firestore.firestore()
        let generalShiftsRef = db.collection("shifts").document()
        
        do {
            try generalShiftsRef.setData(from: shift) { [weak self] error in
                guard let self = self else { return }
                
                if let err = error {
                    self.shiftErrorType = .saving
                    print("Error adding document: \(err)")
                    self.isSaving = false
                } else {
                    print("Document added with ID: \(generalShiftsRef.documentID)")
                    
                    // Ajouter la référence du nouveau shift dans un tableau sous 'offered' dans le document de l'utilisateur
                    let userShiftsRef = db.collection("users").document(userUID).collection("shifts").document("offered")
                    
                    // Commencez par essayer d'ajouter la référence au tableau existant
                    userShiftsRef.updateData(["refs": FieldValue.arrayUnion([generalShiftsRef.documentID])]) { [weak self] error in
                        guard let self = self else { return }
                        
                        if let _ = error {
                            // Si le document 'offered' n'existe pas encore, il faut le créer avec le premier shift
                            userShiftsRef.setData(["refs": [generalShiftsRef.documentID]], merge: true) { error in
                                if let err = error {
                                    self.shiftErrorType = .saving
                                    print("Error creating user shift reference: \(err)")
                                    self.isSaving = false
                                } else {
                                    print("User shift reference created with first ID: \(generalShiftsRef.documentID)")
                                    self.isSaving = false
                                    dismissAction()
                                }
                            }
                        } else {
                            print("User shift reference added with ID: \(generalShiftsRef.documentID)")
                            self.isSaving = false
                            dismissAction()
                        }
                    }
                }
            }
        } catch {
            print(error)
        }
    }
    
    func shiftIsValid() -> Bool {
        guard shift.startTime >= Date() else {
            shiftErrorType = .date
            print("Shift date cannot be in the past.")
            return false
        }
        guard hoursBetweenShiftTimes() != 0 else {
            shiftErrorType = .duration
            print("Shift must be at least 1h.")
            return false
        }
        guard shift.location != "" else {
            shiftErrorType = .location
            print("Please select your location.")
            return false
        }
        shiftErrorType = nil
        return true
    }
    
    // Vérifiez si une mise à jour est nécessaire avant de charger les options
    func loadMenuOptionsIfNeeded() {
        let ref = Database.database().reference(withPath: "dynamicData/locations/lastUpdated")
        ref.observeSingleEvent(of: .value, with: { snapshot in
            if let timestamp = snapshot.value as? TimeInterval, timestamp > self.lastOptionsUpdate {
                self.loadMenuOptions()
                self.lastOptionsUpdate = timestamp
            } else {
                self.menuOptions = self.getCachedMenuOptions().sorted()
            }
        })
    }
    
    // Chargez les options de Firebase et mettez-les en cache
    private func loadMenuOptions() {
        let ref = Database.database().reference(withPath: "dynamicData/locations/options")
        ref.observeSingleEvent(of: .value, with: { snapshot in
            var newOptions: [String] = []
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot,
                   let value = snapshot.value as? String {
                    newOptions.append(value)
                }
            }
            DispatchQueue.main.async {
                self.menuOptions = newOptions.sorted()
                self.cacheMenuOptions(options: newOptions)
            }
        })
    }
    
    // Mettez en cache les options dans UserDefaults
    private func cacheMenuOptions(options: [String]) {
        UserDefaults.standard.set(options, forKey: "cachedMenuOptions")
    }
    
    // Obtenez les options mises en cache de UserDefaults
    private func getCachedMenuOptions() -> [String] {
        return UserDefaults.standard.stringArray(forKey: "cachedMenuOptions") ?? []
    }
}
