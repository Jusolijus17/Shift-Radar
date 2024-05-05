//
//  EditUserProfileViewModel.swift
//  Shift Radar
//
//  Created by Justin Lefrançois on 2024-05-03.
//

import Foundation
import UIKit
import FirebaseStorage
import FirebaseFirestore

class EditUserProfileViewModel: ObservableObject {
    private var userId: String?
    @Published var profileImage: UIImage?
    @Published var firstName: String
    @Published var lastName: String
    @Published var email: String
    @Published var employeeNumber: String
    @Published var phoneNumber: String
    
    @Published var saveState: SaveState = .idle
    
    init(userData: UserData) {
        self.userId = userData.id
        self.firstName = userData.firstName
        self.lastName = userData.lastName
        self.email = userData.email
        self.employeeNumber = userData.employeeNumber
        self.profileImage = userData.profileImage
        self.phoneNumber = userData.phoneNumber ?? ""
    }
    
    func saveInfo() {
        self.saveState = .saving
        
        // Crée une instance de UserData avec les données actuelles
        let updatedUserData = UserData(firstName: firstName, lastName: lastName, email: email, employeeNumber: employeeNumber, phoneNumber: phoneNumber)
        
        // Vérification de l'UserData
        if let userDataError = updatedUserData.verifyInfo() {
            self.saveState = .failed(userDataError)
            return
        }
        
        // Vérification spécifique du ViewModel
        if let viewModelError = self.verifyInfo() {
            self.saveState = .failed(viewModelError)
            return
        }
        
        // Si une photo de profil existe, la téléverser, sinon passer directement à la sauvegarde Firestore
        if let image = profileImage, let userId = userId {
            uploadProfileImage(image, for: userId) { [weak self] success in
                guard success else {
                    self?.saveState = .failed(.updateError)
                    return
                }
                
                // Après le téléversement réussi de l'image, sauvegarder les autres données sur Firestore
                self?.saveToFirestore(updatedData: updatedUserData)
            }
        } else {
            // Pas d'image à téléverser, procéder directement à la sauvegarde sur Firestore
            self.saveToFirestore(updatedData: updatedUserData)
        }
    }
    
    private func verifyInfo() -> ErrorType? {
        if !self.email.contains("@aircanada.ca") {
            return ErrorType.invalidEmail
        }
        
        if self.phoneNumber != "" {
            let phoneRegex = "^\\d{3}-\\d{3}-\\d{4}$"
            let phoneTest = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
            if !phoneTest.evaluate(with: self.phoneNumber) {
                return ErrorType.invalidPhoneNumber
            }
        }
        return nil
    }
    
    private func uploadProfileImage(_ image: UIImage, for userId: String, completion: @escaping (Bool) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.4) else {
            self.saveState = .failed(.encodingError)
            completion(false)
            return
        }

        let storageRef = Storage.storage().reference().child("profilePictures/\(userId)/profile.jpg")
        storageRef.putData(imageData, metadata: nil) { metadata, error in
            guard metadata != nil else {
                DispatchQueue.main.async {
                    self.saveState = .failed(.updateError)
                    completion(false)
                }
                return
            }

            completion(true)
        }
    }
    
    private func saveToFirestore(updatedData: UserData) {
        guard let userId else {
            self.saveState = .failed(.invalidUserID)
            return
        }

        let db = Firestore.firestore()
        let userRef = db.collection("users").document(userId)

        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(updatedData)
            guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
                self.saveState = .failed(.encodingError)
                return
            }

            userRef.setData(dictionary) { error in
                if let error = error {
                    DispatchQueue.main.async {
                        self.saveState = .failed(.updateError)
                    }
                    return
                }
                
                DispatchQueue.main.async {
                    self.saveState = .saved
                }
            }
        } catch {
            DispatchQueue.main.async {
                self.saveState = .failed(.encodingError)
            }
        }
    }
}


enum SaveState {
    case idle
    case saving
    case saved
    case failed(ErrorType)
}

