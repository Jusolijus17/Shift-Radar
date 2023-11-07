//
//  OfferShiftViewModel.swift
//  Shift Radar
//
//  Created by Justin Lefrançois on 2023-11-03.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseDatabase
import FirebaseAuth
import Foundation

// Make CompensationType conform to Codable
enum CompensationType: String, Codable {
    case give
    case sell
    case trade
}

// Make Availability conform to Codable
struct Availability: Codable {
    var date: Date
    var startTime: Date
    var endTime: Date
}

// Make Shift conform to Codable
struct Shift: Codable {
    //@DocumentID var id: String?
    var date: Date
    var startTime: Date
    var endTime: Date
    var location: String
    var compensationType: CompensationType
    var moneyCompensation: Double
    var availabilities: [Availability]
    
    init() {
        self.date = Date()
        self.startTime = Date()
        self.endTime = Date()
        self.location = ""
        self.compensationType = .give
        self.moneyCompensation = 0
        self.availabilities = []
    }
    
    // Custom keys for encoding and decoding
    enum CodingKeys: String, CodingKey {
        case date
        case startTime
        case endTime
        case location
        case compensationType
        case moneyCompensation
        case availabilities
    }
    
    // Custom initializer from decoder
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        date = try container.decode(Date.self, forKey: .date)
        startTime = try container.decode(Date.self, forKey: .startTime)
        endTime = try container.decode(Date.self, forKey: .endTime)
        location = try container.decode(String.self, forKey: .location)
        let compensationTypeString = try container.decode(String.self, forKey: .compensationType)
        guard let compensationType = CompensationType(rawValue: compensationTypeString) else {
            throw DecodingError.dataCorruptedError(forKey: .compensationType,
                in: container,
                debugDescription: "CompensationType does not match any known value")
        }
        self.compensationType = compensationType
        moneyCompensation = try container.decode(Double.self, forKey: .moneyCompensation)
        availabilities = try container.decode([Availability].self, forKey: .availabilities)
    }
    
    // Custom encode function
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(date, forKey: .date)
        try container.encode(startTime, forKey: .startTime)
        try container.encode(endTime, forKey: .endTime)
        try container.encode(location, forKey: .location)
        try container.encode(compensationType.rawValue, forKey: .compensationType)
        try container.encode(moneyCompensation, forKey: .moneyCompensation)
        try container.encode(availabilities, forKey: .availabilities)
    }
}

class OfferShiftViewModel: ObservableObject {
    @Published var isEmpty: Bool = true
    @Published var error: String?
    @Published var isSaving: Bool = false
    
    @Published var menuOptions: [String] = [] {
        didSet {
            shiftData.location = menuOptions[0]
        }
    }
    
    // Modal
    @Published var showModal: Bool = false
    
    // Shift data
    @Published var shiftData: Shift
    
    // Timestamp de la dernière mise à jour des options
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
        
        self.shiftData = newShift
        loadMenuOptions()
    }
    
    func hoursBetweenShiftTimes() -> Int {
        let calendar = Calendar.current
        var hours = calendar.dateComponents([.hour], from: shiftData.startTime, to: shiftData.endTime).hour ?? 0
        if hours < 0 {
            hours += 24
        }
        
        return hours
    }
    
    func changeCompensationType(newValue: CompensationType) {
        shiftData.compensationType = newValue
    }
    
    func saveShift(dismissAction: @escaping () -> Void) {
        guard shiftIsValid() else { return }
        isSaving = true
        
//        let shiftDict: [String: Any] = [
//            "date": Timestamp(date: shiftData.date),
//            "startTime": Timestamp(date: shiftData.startTime),
//            "endTime": Timestamp(date: shiftData.endTime),
//            "location": shiftData.location,
//            "compensationType": String(describing: shiftData.compensationType),
//            "moneyCompensation": shiftData.moneyCompensation,
//            "availabilities": shiftData.availabilities.map { availability in
//                return [
//                    "date": Timestamp(date: availability.date),
//                    "startTime": Timestamp(date: availability.startTime),
//                    "endTime": Timestamp(date: availability.endTime)
//                ]
//            }
//        ]
        
        // debugging
        Auth.auth().signIn(withEmail: "testaccount@aircanada.ca", password: "Bosesony2011")
        
        guard let userUID = Auth.auth().currentUser?.uid else {
            print( "User must be logged in to save a shift.")
            self.isSaving = false
            return
        }
        
        // Référence à la base de données Firestore
        let db = Firestore.firestore()
        let generalShiftsRef = db.collection("shifts").document()
        
        do {
            try generalShiftsRef.setData(from: shiftData) { [weak self] error in
                guard let self = self else { return }
                
                if let err = error {
                    self.error = "Error adding document: \(err)"
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
                                    self.error = "Error creating user shift reference: \(err)"
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
        guard hoursBetweenShiftTimes() != 0 else {
            error = "Your shift must be at least 1h."
            return false
        }
        guard shiftData.location != "" else {
            error = "Please select your location."
            return false
        }
        return true
    }
    
    // Vérifiez si une mise à jour est nécessaire avant de charger les options
    private func loadMenuOptionsIfNeeded() {
        let ref = Database.database().reference(withPath: "dynamicData/locations/lastUpdated")
        ref.observeSingleEvent(of: .value, with: { snapshot in
            if let timestamp = snapshot.value as? TimeInterval, timestamp > self.lastOptionsUpdate {
                self.loadMenuOptions()
                self.lastOptionsUpdate = timestamp
            } else {
                self.menuOptions = self.getCachedMenuOptions()
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
                self.menuOptions = newOptions
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
    
    private func getMyOffers() {
        
    }
    
}

