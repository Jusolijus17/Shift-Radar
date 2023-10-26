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

struct SignUpView: View {
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    
    @State private var image = UIImage()
    @State private var showSheet = false
    
    @ObservedObject var userData = UserData()
    @Environment(\.presentationMode) var presentationMode
    
    @State private var isLoading: Bool = false
    @State private var error: String?
    
    var body: some View {
        
        VStack {
            Button(action: {
                showSheet = true
            }, label: {
                if let profileImage = userData.profileImage {
                    Image(uiImage: profileImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 140, height: 140)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .shadow(radius: 10)
                } else {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(.white)
                        .stroke(Color(hex: "#D7EAE7"), lineWidth: 1.5)
                        .frame(width: 140, height: 140)
                        .shadow(radius: 10)
                        .overlay {
                            VStack {
                                Image(systemName: "camera")
                                    .font(.title2)
                                    .padding(.bottom, 0.5)
                                Text("Add profile picture")
                            }
                            .foregroundStyle(Color(hex: "#B9BBBE"))
                        }
                }
            })
            
            Spacer()
            
            VStack(spacing: 18) {
                HStack {
                    Group {
                        CustomTextField(text: $userData.firstName, placeholder: "First", systemName: "person.fill")
                        CustomTextField(text: $userData.lastName, placeholder: "Last", systemName: "person")
                    }
                    .padding()
                    .background {
                        RoundedRectangle(cornerRadius: 10.0)
                            .fill(.white)
                            .stroke(Color(hex: "#D7EAE7"), lineWidth: 1.5)
                    }
                }
                
                Group {
                    HStack {
                        CustomTextField(text: $userData.email, placeholder: "Email", systemName: "envelope")
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                        Text("@aircanada.ca")
                            .foregroundStyle(Color(hex: "#8B8E94"))
                            .padding(.trailing, 10)
                    }
                    HStack {
                        Label("AC", systemImage: "number")
                            .foregroundStyle(.tertiary)
                        Divider()
                            .frame(maxHeight: 25)
                            .padding(.horizontal, 5)
                        TextField("Employee Number", text: $userData.employeeNumber)
                            .keyboardType(.numberPad)
                    }
                    CustomSecureField(text: $password, placeholder: "Password", systemName: "lock")
                    CustomSecureField(text: $confirmPassword, placeholder: "Confirm Password", systemName: "lock.fill")
                }
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 10.0)
                        .fill(.white)
                        .stroke(Color(hex: "#D7EAE7"), lineWidth: 1.5)
                }
            }
            
            Spacer()
            
            if let error = error {
                Text(error)
                    .foregroundStyle(.red)
            }
            
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
        .padding()
        .background {
            VStack {
                Spacer()
                Circle()
                    .fill(Color(hex: "#000920"))
                    .frame(width: 1100, height: 1100)
                    .offset(y: 700)
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
    }
    
    func createAccount() {
        if verifyInfo() {
            isLoading = true // commence le chargement
            Auth.auth().createUser(withEmail: "\(userData.email)@aircanada.ca", password: password) { authResult, error in
                if let error = error {
                    self.error = error.localizedDescription
                    self.isLoading = false
                    return
                }
                
                if let uid = authResult?.user.uid {
                    // Si la photo de profil existe
                    if let profileImage = self.userData.profileImage,
                       let data = profileImage.jpegData(compressionQuality: 0.5) {
                        let storageRef = Storage.storage().reference().child("profile_images").child("\(uid).jpeg")
                        
                        storageRef.putData(data, metadata: nil) { (metadata, err) in
                            if let err = err {
                                self.error = "Error uploading profile image: \(err.localizedDescription)"
                                self.isLoading = false
                                return
                            }
                            
                            storageRef.downloadURL { (url, err) in
                                if let err = err {
                                    self.error = "Error fetching profile image URL: \(err.localizedDescription)"
                                    self.isLoading = false
                                    return
                                }
                                
                                if let profileImageUrl = url?.absoluteString {
                                    let db = Firestore.firestore()
                                    db.collection("users").document(uid).setData([
                                        "firstName": self.userData.firstName,
                                        "lastName": self.userData.lastName,
                                        "employeeNumber": self.userData.employeeNumber,
                                        "profileImageUrl": profileImageUrl
                                    ]) { err in
                                        self.isLoading = false
                                        if let err = err {
                                            self.error = "Error saving user data: \(err.localizedDescription)"
                                        } else {
                                            print("Account and user data created!")
                                        }
                                    }
                                }
                            }
                        }
                    } else {
                        // Si l'utilisateur n'a pas choisi d'image de profil
                        let db = Firestore.firestore()
                        db.collection("users").document(uid).setData([
                            "firstName": self.userData.firstName,
                            "lastName": self.userData.lastName,
                            "employeeNumber": self.userData.employeeNumber
                        ]) { err in
                            self.isLoading = false
                            if let err = err {
                                self.error = "Error saving user data: \(err.localizedDescription)"
                            } else {
                                print("Account and user data created!")
                            }
                        }
                    }
                }
            }
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
