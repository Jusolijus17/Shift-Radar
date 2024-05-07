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
    private var originalImage: UIImage?
    
    init(userData: UserData) {
        self.userId = userData.id
        self.firstName = userData.firstName
        self.lastName = userData.lastName
        if let firstPart = userData.email.split(separator: "@").first {
            self.email = String(firstPart)
        } else {
            self.email = userData.email
        }
        self.employeeNumber = userData.employeeNumber
        self.profileImage = userData.profileImage
        self.originalImage = userData.profileImage
        self.phoneNumber = userData.phoneNumber ?? ""
    }

    
    func saveInfo() {
        self.saveState = .saving
        
        let updatedUserData = UserData(firstName: firstName, lastName: lastName, email: email,
                                       employeeNumber: employeeNumber, phoneNumber: phoneNumber)
        
        if let userDataError = updatedUserData.verifyInfo() {
            self.saveState = .failed(userDataError)
            return
        }
        
        if let viewModelError = verifyInfo(updatedUserData) {
            self.saveState = .failed(viewModelError)
            return
        }
        
        if let image = profileImage, let userId = userId {
            let newImageData = image.jpegData(compressionQuality: 0.9)
            let oldImageData = originalImage?.jpegData(compressionQuality: 0.9)
            
            if newImageData != oldImageData {
                uploadProfileImage(image, for: userId) { [weak self] success in
                    guard success else {
                        self?.saveState = .failed(.updateError)
                        return
                    }
                    self?.saveToFirestore(updatedData: updatedUserData)
                }
            } else {
                saveToFirestore(updatedData: updatedUserData)
            }
        } else if originalImage != nil, let userId = userId {
            deleteProfileImage(for: userId) { [weak self] success in
                guard success else {
                    self?.saveState = .failed(.updateError)
                    return
                }
                self?.saveToFirestore(updatedData: updatedUserData)
            }
        } else {
            saveToFirestore(updatedData: updatedUserData)
        }
    }
    
    private func verifyInfo(_ updatedUserData: UserData) -> ErrorType? {
        if updatedUserData.email.contains("@aircanada.ca") {
            return ErrorType.invalidEmail
        } else {
            updatedUserData.email += "@aircanada.ca"
        }
        
        if let phoneNumber = updatedUserData.phoneNumber, phoneNumber != "" {
            let phoneRegex = "^\\d{3}-\\d{3}-\\d{4}$"
            let phoneTest = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
            if !phoneTest.evaluate(with: phoneNumber) {
                return ErrorType.invalidPhoneNumber
            }
        }
        return nil
    }
    
    private func uploadProfileImage(_ image: UIImage, for userId: String, completion: @escaping (Bool) -> Void) {
        guard let resizedImage = resizeImage(image: image, targetSize: CGSize(width: 300, height: 300)),
              let imageData = resizedImage.jpegData(compressionQuality: 0.7) else {
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
    
    private func deleteProfileImage(for userId: String, completion: @escaping (Bool) -> Void) {
        let storageRef = Storage.storage().reference().child("profilePictures/\(userId)/profile.jpg")
        storageRef.delete { error in
            if let error = error {
                print("Error removing profile image: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.saveState = .failed(.updateError)
                    completion(false)
                }
            } else {
                print("Profile image successfully removed")
                DispatchQueue.main.async {
                    completion(true)
                }
            }
        }
    }
    
    private func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage? {
        let size = image.size

        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height

        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }

        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)

        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
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

            userRef.updateData(dictionary) { error in
                if let error {
                    print("Error saving to firestore : ", error.localizedDescription)
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


enum SaveState: Equatable {
    case idle
    case saving
    case saved
    case failed(ErrorType)
}

