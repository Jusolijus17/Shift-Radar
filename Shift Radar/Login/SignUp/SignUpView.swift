//
//  SignUpView.swift
//  Shift Radar
//
//  Created by Justin Lefrançois on 2023-10-24.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

enum AccountCreationState {
    case basicInfo, emailConfirmation, success
}

struct SignUpView: View {
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    
    @State private var image = UIImage()
    @State private var showSheet = false
    
    @StateObject var userData = UserData()
    @Environment(\.presentationMode) var presentationMode
    
    @State private var isLoading: Bool = false
    @State private var error: String?
    
    @State private var accountCreationState = AccountCreationState.basicInfo
    
    var body: some View {
        
        VStack {
            if accountCreationState == .emailConfirmation {
                Spacer()
            }
            if accountCreationState == .basicInfo || accountCreationState == .emailConfirmation {
                PictureView(showSheet: $showSheet)
                    .padding(.top)
            }
            if accountCreationState == .basicInfo {
                Spacer()
                InfoView(password: $password, confirmPassword: $confirmPassword).transition(.move(edge: .leading))
                Spacer()
            } else if accountCreationState != .emailConfirmation {
                EmailConfirmView()
            }
            
            if let error = error {
                Text(error)
                    .foregroundStyle(.red)
            }
            
            Spacer()
            
            Button("Already have an account? Login.") {
                presentationMode.wrappedValue.dismiss()
            }
            .disabled(isLoading)
            
            Button(action: {
                createAccount()
            }, label: {
                if isLoading {
                    ProgressView()
                        .frame(width: 25, height: 25)
                } else {
                    Text("Create Account")
                }
            })
            .frame(maxWidth: .infinity)
            .fontWeight(.semibold)
            .foregroundStyle(.white)
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 25.0)
                    .fill(Color.accentColor)
            }
            .opacity(isLoading ? 0.6 : 1)
            .padding(.horizontal)
            .disabled(isLoading)
            
        }
        .background {
            VStack {
                Spacer()
                Circle()
                    .fill(Color.accentColor2)
                    .frame(width: 1100, height: 1100)
                    .offset(y: accountCreationState == .basicInfo ? 700: 600)
            }
            .background(Color(hex: "#F2F2F2"))
            .ignoresSafeArea()
        }
        .sheet(isPresented: $showSheet) {
            ImagePicker(sourceType: .photoLibrary, selectedImage: self.$image)
                .onDisappear(perform: {
                    userData.profileImage = image
                })
        }
        .environmentObject(userData)
    }
    
    func createAccount() {
        withAnimation(.spring(duration: 0.5)) {
            accountCreationState = .emailConfirmation
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

struct ImagePicker: UIViewControllerRepresentable {
    @Environment(\.presentationMode) private var presentationMode
    var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @Binding var selectedImage: UIImage
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = false
        imagePicker.sourceType = sourceType
        imagePicker.delegate = context.coordinator
        
        return imagePicker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        
        var parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            
            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            
            parent.presentationMode.wrappedValue.dismiss()
        }
        
    }
}

#Preview {
    SignUpView()
}
