//
//  SignUpViewModel.swift
//  Shift Radar
//
//  Created by Justin Lefrançois on 2023-11-02.
//

import Foundation
import SwiftUI

class SignUpViewModel: ObservableObject {
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var userData = UserData()
    @Published var isLoading: Bool = false
    @Published var error: String?
    @Published var accountCreationState = AccountCreationState.basicInfo
    @Published var backgroundHeightMultiplier: CGFloat = 0.32
    @Published var labelText: String = "One last step..."
    
    var buttonText: String {
        switch accountCreationState {
        case .basicInfo:
            return "Create Account"
        case .emailConfirmation:
            return "Waiting verification..."
        case .success:
            return "Enter Shift-Radar"
        }
    }
    
    func createAccount() {
        withAnimation(.spring(duration: 0.5)) {
            accountCreationState = .emailConfirmation
            backgroundHeightMultiplier = 0.38
        }
//        if verifyInfo() {
//            isLoading = true // commence le chargement
//            Auth.auth().createUser(withEmail: "\(userData.email)@aircanada.ca", password: password) { authResult, error in
//                if let error = error {
//                    self.error = error.localizedDescription
//                    self.isLoading = false
//                    return
//                }
//
//                if let uid = authResult?.user.uid {
//                    // Si la photo de profil existe
//                    if let profileImage = self.userData.profileImage,
//                       let data = profileImage.jpegData(compressionQuality: 0.5) {
//                        let storageRef = Storage.storage().reference().child("profile_images").child("\(uid).jpeg")
//
//                        storageRef.putData(data, metadata: nil) { (metadata, err) in
//                            if let err = err {
//                                self.error = "Error uploading profile image: \(err.localizedDescription)"
//                                self.isLoading = false
//                                return
//                            }
//
//                            storageRef.downloadURL { (url, err) in
//                                if let err = err {
//                                    self.error = "Error fetching profile image URL: \(err.localizedDescription)"
//                                    self.isLoading = false
//                                    return
//                                }
//
//                                if let profileImageUrl = url?.absoluteString {
//                                    let db = Firestore.firestore()
//                                    db.collection("users").document(uid).setData([
//                                        "firstName": self.userData.firstName,
//                                        "lastName": self.userData.lastName,
//                                        "employeeNumber": self.userData.employeeNumber,
//                                        "profileImageUrl": profileImageUrl
//                                    ]) { err in
//                                        self.isLoading = false
//                                        if let err = err {
//                                            self.error = "Error saving user data: \(err.localizedDescription)"
//                                        } else {
//                                            print("Account and user data created!")
//                                            withAnimation {
//                                                accountCreated = true
//                                            }
//                                        }
//                                    }
//                                }
//                            }
//                        }
//                    } else {
//                        // Si l'utilisateur n'a pas choisi d'image de profil
//                        let db = Firestore.firestore()
//                        db.collection("users").document(uid).setData([
//                            "firstName": self.userData.firstName,
//                            "lastName": self.userData.lastName,
//                            "employeeNumber": self.userData.employeeNumber
//                        ]) { err in
//                            self.isLoading = false
//                            if let err = err {
//                                self.error = "Error saving user data: \(err.localizedDescription)"
//                            } else {
//                                print("Account and user data created!")
//                            }
//                        }
//                    }
//                }
//            }
//        }
    }
    
    func verifyEmail() {
        labelText = "Account created!"
        withAnimation(.spring(duration: 0.5)) {
            accountCreationState = .success
            backgroundHeightMultiplier = 1
        }
    }
    
    func verifyInfo() -> Bool {
        // Vérification du prénom
        if userData.firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            error = "First name is required."
            return false
        }
        
        // Vérification du nom de famille
        if userData.lastName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            error = "Last name is required."
            return false
        }
        
        // Vérification de l'email
        if userData.email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            error = "Email is required."
            return false
        } else if userData.email.contains("@") {
            error = "Please remove @ from email. The @aircanada.ca will be added automatically."
            return false
        }
        
        // Vérification du numéro d'employé
        if userData.employeeNumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            error = "Employee number is required."
            return false
        }
        
        // Vérification du mot de passe
        if password.isEmpty || confirmPassword.isEmpty {
            error = "Please fill in both password fields."
            return false
        } else if password != confirmPassword {
            error = "Passwords do not match."
            return false
        } else if password.count < 8 {
            error = "Password should be at least 8 characters long."
            return false
        }
        
        // Si toutes les vérifications sont passées
        error = nil
        return true
    }
}

enum AccountCreationState {
    case basicInfo, emailConfirmation, success
}
