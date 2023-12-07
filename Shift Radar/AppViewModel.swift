//
//  AppViewModel.swift
//  Shift Radar
//
//  Created by Justin Lefrançois on 2023-11-29.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class AppViewModel: ObservableObject {
    @Published var userData: UserData?
    @Published var isLoading: Bool = false
    @Published var loadingError: Error?

    func loadUserData() {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }

        isLoading = true
        let db = Firestore.firestore()
        db.collection("users").document(uid).getDocument(as: UserData.self) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let userData):
                    self?.userData = userData
                case .failure(let error):
                    self?.loadingError = error
                    print("Error decoding user data: \(error)")
                }
            }
        }
    }
}

