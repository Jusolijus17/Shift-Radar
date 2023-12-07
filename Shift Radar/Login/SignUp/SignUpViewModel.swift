//
//  SignUpViewModel.swift
//  Shift Radar
//
//  Created by Justin Lefrançois on 2023-11-02.
//

import Foundation
import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth
import FirebaseStorage
import FirebaseFunctions

class SignUpViewModel: ObservableObject {
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var userData = UserData()
    @Published var isLoading: Bool = false
    @Published var error: String?
    @Published var accountCreationState = AccountCreationState.basicInfo
    @Published var backgroundHeightMultiplier: CGFloat = 0.32
    @Published var labelText: String = "One last step..."
    @Published var profilePicture: UIImage?
    
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
        guard verifyInfo() else { return }
        self.isLoading = true
        
        let functions = Functions.functions()
        let data = userData.toDictionary()
        
        Auth.auth().createUser(withEmail: "\(userData.email)@aircanada.ca", password: password) { authResult, error in
            if let error = error {
                self.error = error.localizedDescription
                self.isLoading = false
                return
            }
            
            functions.httpsCallable("createAccount").call(data) { [weak self] result, error in
                if let error = error as NSError? {
                    self?.handleError(error)
                    return
                }
                
                print("Compte créé avec succès.")
                self?.uploadProfilePictureIfNeeded { success in
                    if success {
                        self?.updateUI()
                    } else {
                        self?.error = "Error uploading profile picture"
                        self?.isLoading = false
                    }
                }
            }
        }
    }
    
    private func handleError(_ error: NSError) {
        self.isLoading = false
        if error.domain == FunctionsErrorDomain {
            let code = FunctionsErrorCode(rawValue: error.code)
            let message = error.localizedDescription
            let details = error.userInfo[FunctionsErrorDetailsKey]
            if let code = code, let details = details {
                print("Error \(code) \(message) \(details)")
            } else {
                print("Error \(message)")
            }
        }
        self.error = "Error calling cloud function"
    }
    
    private func uploadProfilePictureIfNeeded(completion: @escaping (Bool) -> Void) {
        if let profilePicture = self.profilePicture {
            self.uploadProfilePicture(profilePicture) { result in
                switch result {
                case .success(let url):
                    self.userData.profileImageUrl = url
                    completion(true)
                case .failure(let error):
                    print("Error uploading profile picture: \(error)")
                    completion(false)
                }
            }
        } else {
            completion(true)
        }
    }
    
    private func uploadProfilePicture(_ image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(.failure(ImageUploadError.noUser))
            return
        }
        guard let imageData = image.jpegData(compressionQuality: 0.4) else {
            completion(.failure(ImageUploadError.imageConversionFailed))
            return
        }

        let storageRef = Storage.storage().reference().child("profilePictures/\(uid)/profile.jpg")
        storageRef.putData(imageData, metadata: nil) { metadata, error in
            guard metadata != nil else {
                completion(.failure(error ?? ImageUploadError.uploadFailed))
                return
            }
            
            storageRef.downloadURL { url, error in
                guard let downloadURL = url else {
                    completion(.failure(error ?? ImageUploadError.urlRetrievalFailed))
                    return
                }
                completion(.success(downloadURL.absoluteString))
            }
        }
    }
    
    private func updateUI() {
        withAnimation(.spring(duration: 0.5)) {
            self.accountCreationState = .emailConfirmation
            self.backgroundHeightMultiplier = 0.38
        }
        self.isLoading = false
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

enum ImageUploadError: Error {
    case noUser
    case imageConversionFailed
    case uploadFailed
    case urlRetrievalFailed
}


enum AccountCreationState {
    case basicInfo, emailConfirmation, success
}
