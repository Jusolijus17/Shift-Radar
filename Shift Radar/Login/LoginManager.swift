//
//  LoginManager.swift
//  Shift Radar
//
//  Created by Justin Lefrançois on 2023-10-24.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct LoginManager: View {
    @StateObject private var userData = UserData()
    @State private var isUserLoggedIn: Bool = (Auth.auth().currentUser != nil)

    var body: some View {
        Group {
            if isUserLoggedIn {
                TabViewManager()
                    .environmentObject(userData)
            } else {
                LoginView()
            }
        }
        .onAppear {
            Auth.auth().addStateDidChangeListener { (auth, user) in
                withAnimation {
                    self.isUserLoggedIn = (user != nil)
                    if self.isUserLoggedIn {
                        self.loadUserData()
                    }
                }
            }
        }
    }

    func loadUserData() {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let db = Firestore.firestore()
        db.collection("users").document(uid).getDocument { (document, error) in
            if let document = document, document.exists {
                let data = document.data()
                self.userData.firstName = data?["firstName"] as? String ?? ""
                self.userData.lastName = data?["lastName"] as? String ?? ""
                self.userData.email = Auth.auth().currentUser?.email ?? ""
                self.userData.employeeNumber = data?["employeeNumber"] as? String ?? ""
                if let profileImageUrl = data?["profileImageUrl"] as? String {
                    // charger l'image depuis l'URL
                    if let url = URL(string: profileImageUrl) {
                        URLSession.shared.dataTask(with: url) { data, response, error in
                            if let data = data, let image = UIImage(data: data) {
                                DispatchQueue.main.async {
                                    self.userData.profileImage = image
                                }
                            }
                        }.resume()
                    }
                }
            } else {
                print("Document does not exist.")
            }
        }
    }
}


class UserData: ObservableObject {
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var email: String = ""
    @Published var employeeNumber: String = ""
    @Published var profileImage: UIImage?
}


#Preview {
    LoginManager()
}
