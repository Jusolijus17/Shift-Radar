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
    @Published var uid: String?
    @Published var userData: UserData?
    @Published var isLoading: Bool = false
    @Published var loadingError: Error?
    
    init() {
        self.uid = Auth.auth().currentUser?.uid
    }

    func loadUserData() {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }

        isLoading = true
        let db = Firestore.firestore()
        db.collection("users").document(uid).getDocument(as: UserData.self) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let userData):
                    self?.userData = userData
                    // Charger l'image si l'URL est disponible
                    if let urlString = userData.profileImageUrl, let url = URL(string: urlString) {
                        self?.loadImage(from: url)
                    }
                case .failure(let error):
                    self?.loadingError = error
                    print("Error decoding user data: \(error)")
                }
                self?.isLoading = false
            }
        }
    }

    func loadImage(from url: URL) {
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let data = data, error == nil else {
                print("Failed to load image data: \(String(describing: error))")
                return
            }
            if let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self?.userData?.profileImage = image
                    self?.objectWillChange.send()
                }
            }
        }
        task.resume()
    }
}

