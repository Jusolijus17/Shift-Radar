//
//  EditProfileView.swift
//  Shift Radar
//
//  Created by Justin Lefrançois on 2024-05-02.
//

import SwiftUI

struct EditUserProfileView: View {
    @StateObject private var viewModel: EditUserProfileViewModel
    @Binding var isEditing: Bool
    @State private var showImagePicker: Bool = false
    @State private var selectedImage: UIImage?
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var alertTitle: String = ""

    init(userData: UserData, isEditing: Binding<Bool>) {
        _isEditing = isEditing
        _viewModel = StateObject(wrappedValue: EditUserProfileViewModel(userData: userData))
    }
    
    var body: some View {
        VStack {
            ScrollView {
                Group {
                    ProfileImage(image: $selectedImage, width: 100, height: 100, placeholder: {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .clipShape(Circle())
                    })
                    .editable()
                    .padding(.vertical)
                    .onAppear {
                        self.selectedImage = viewModel.profileImage
                    }
                    
                    HStack {
                        CustomTextField(text: $viewModel.firstName, placeholder: "First name", systemName: "person.fill")
                            .outlined()
                        CustomTextField(text: $viewModel.lastName, placeholder: "Last name", systemName: "person")
                            .outlined()
                    }
                    
                    CustomTextField(text: $viewModel.email, placeholder: "Email", systemName: "envelope")
                        .outlined()
                    
                    EmployeeNumberField(number: $viewModel.employeeNumber)
                        .outlined()
                    
                    CustomTextField(text: $viewModel.phoneNumber, placeholder: "Add phone number", systemName: "phone")
                        .outlined()
                }
                .padding(.horizontal)
            }
            
            Spacer()
            
            HStack {
                Button {
                    self.viewModel.profileImage = selectedImage
                    viewModel.saveInfo()
                } label: {
                    Text("Save")
                        .foregroundColor(.white)
                        .padding()
                        .bold()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                
                Button {
                    self.isEditing = false
                } label: {
                    Text("Cancel")
                        .foregroundColor(.red)
                        .bold()
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.red, lineWidth: 2)
                        }
                }
            }
            .padding(.horizontal)
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(sourceType: .photoLibrary, selectedImage: $selectedImage)
                .onDisappear {
                    viewModel.profileImage = selectedImage
                }
        }
        .navigationTitle("Edit profile")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.background)
        .ignoresSafeArea(.keyboard)
        .onReceive(viewModel.$saveState) { state in
            switch state {
            case .failed(let error):
                alertTitle = "Error"
                alertMessage = error.rawValue
                showAlert = true
            case .saved:
                alertTitle = "Success"
                alertMessage = "Profile updated successfully!"
                showAlert = true
                isEditing = false // Close editing view on success
            default:
                break
            }
        }
    }
}


struct EditUserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper()
    }
    
    struct PreviewWrapper: View {
        @State private var userData = UserData.dummyUser()
        
        var body: some View {
            NavigationView {
                EditUserProfileView(userData: userData, isEditing: .constant(true))
            }
        }
    }
}
