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

class OfferShiftViewModel: ObservableObject {
    @Published var error: String?
    @Published var isSaving: Bool = false
    
    @Published var menuOptions: [String] = [] {
        didSet {
            shiftData.location = menuOptions[0]
        }
    }
    
    @Published var offeredShifts: [Shift] = []
    private var shiftsListener: ListenerRegistration?
    
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
        fetchOfferedShifts()
    }
    
    deinit {
        print("DEINIT called")
        stopListeningToOfferedShifts()
    }
    
    func hoursBetweenShiftTimes() -> Int {
        let calendar = Calendar.current
        var hours = calendar.dateComponents([.hour], from: shiftData.startTime, to: shiftData.endTime).hour ?? 0
        if hours < 0 {
            hours += 24
        }
        
        return hours
    }
    
    func refreshEndTime(_ oldValue: Date, _ newValue: Date) {
        let calendar = Calendar.current
        
        let currentComponents = calendar.dateComponents([.year, .month, .day], from: oldValue)
        let newComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: newValue)
        
        let endTimeComponents = calendar.dateComponents([.hour, .minute], from: shiftData.endTime)
        
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
                    shiftData.endTime = newEndTime
                }
            }
        }
    }
    
    func changeCompensationType(newValue: CompensationType) {
        shiftData.compensationType = newValue
        
        
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
    func loadMenuOptionsIfNeeded() {
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
    
    private func fetchOfferedShifts() {
        //debugging
        Auth.auth().signIn(withEmail: "testaccount@aircanada.ca", password: "Bosesony2011")
        
        guard let userUID = Auth.auth().currentUser?.uid else {
            print("User must be logged in to fetch offered shifts.")
            return
        }
        
        let db = Firestore.firestore()
        let userShiftsRef = db.collection("users").document(userUID).collection("shifts").document("offered")

        shiftsListener = userShiftsRef.addSnapshotListener { [weak self] (documentSnapshot, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("Error listening for offered shifts updates: \(error)")
                self.error = "Error listening for offered shifts updates: \(error)"
                return
            }

            guard let documentSnapshot = documentSnapshot, documentSnapshot.exists,
                  let refs = documentSnapshot.data()?["refs"] as? [String] else {
                print("Document does not exist or 'refs' field is missing.")
                return
            }

            // Array to hold the fetched shifts
            var fetchedShifts: [Shift] = []
            let group = DispatchGroup()

            for ref in refs {
                group.enter()
                let shiftRef = db.collection("shifts").document(ref)
                shiftRef.getDocument { (shiftDoc, err) in
                    defer { group.leave() }
                    if let err = err {
                        print("Error fetching shift: \(err)")
                    } else if let shiftDoc = shiftDoc, shiftDoc.exists {
                        do {
                            let shift = try shiftDoc.data(as: Shift.self)
                            fetchedShifts.append(shift)
                        } catch {
                            print("Error decoding shift: \(error)")
                        }
                    }
                }
            }

            // Wait for all fetches to complete
            group.notify(queue: .main) {
                self.offeredShifts = fetchedShifts
            }
        }
    }
    
    private func stopListeningToOfferedShifts() {
        shiftsListener?.remove()
        shiftsListener = nil
    }
    
    func deleteShift(_ id: String?) {
        guard let id = id else { return }
        
        //debugging
        Auth.auth().signIn(withEmail: "testaccount@aircanada.ca", password: "Bosesony2011")
        
        guard let userUID = Auth.auth().currentUser?.uid else {
            print("User must be logged in to delete a shift.")
            return
        }
        
        let db = Firestore.firestore()
        
        // Créez une référence au document shift dans la collection 'shifts'
        let shiftRef = db.collection("shifts").document(id)
        
        // Commencez par supprimer le shift lui-même
        shiftRef.delete { error in
            if let error = error {
                print("Error deleting shift document: \(error)")
            } else {
                print("Shift successfully deleted")
            }
        }
        
        // Ensuite, supprimez la référence de ce shift dans le tableau 'refs' du document 'offered'
        let userShiftsRef = db.collection("users").document(userUID).collection("shifts").document("offered")
        
        // Utilisez FieldValue.arrayRemove pour supprimer l'ID du shift du tableau 'refs'
        userShiftsRef.updateData(["refs": FieldValue.arrayRemove([id])]) { error in
            if let error = error {
                print("Error removing shift reference from user document: \(error)")
            } else {
                print("Shift reference successfully removed from user document")
            }
        }
    }
}

