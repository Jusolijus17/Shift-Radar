//
//  ProfileViewModel.swift
//  Shift Radar
//
//  Created by Justin Lefrançois on 2024-05-02.
//

import UIKit
import FirebaseAuth
import FirebaseFunctions

class UserProfileViewModel: ObservableObject {
    @Published var isEditing = false
    @Published var shouldRelaodUserData = false
    @Published var profileImage: UIImage?
    @Published var showingDeleteAlert = false
    @Published var isDeletingAccount = false
    
    func deleteAccount() {
        let functions = Functions.functions()
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User ID not found")
            return
        }
        isDeletingAccount = true
        
        functions.httpsCallable("deleteAccount").call(["userId": userId]) { result, error in
            if let error = error as NSError? {
                if error.domain == FunctionsErrorDomain {
                    let code = FunctionsErrorCode(rawValue: error.code) ?? FunctionsErrorCode.unknown
                    let message = error.localizedDescription
                    let details = error.userInfo[FunctionsErrorDetailsKey] ?? "No details available"
                    print("Error code: \(code); message: \(message); details: \(details)")
                }
                // Handle the error here
                print("Error calling cloud function: \(error.localizedDescription)")
                self.isDeletingAccount = false
            } else if let resultData = result?.data as? [String: Any] {
                // Handle the result here if your function returns data
                print("Function result: \(resultData)")
                self.isDeletingAccount = false
                self.logout()
            }
        }
    }
    
    private func logout() {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
}
