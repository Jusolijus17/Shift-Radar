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
    @Binding var shouldReloadUserData: Bool
    
    @State private var showImagePicker: Bool = false
    @State private var selectedImage: UIImage?
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var alertTitle: String = ""

    init(userData: UserData, isEditing: Binding<Bool>, shouldReloadUserData: Binding<Bool>) {
        _isEditing = isEditing
        _shouldReloadUserData = shouldReloadUserData
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
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                    })
                    .editable()
                    .padding(.vertical)
                    .onAppear {
                        self.selectedImage = viewModel.profileImage
                    }
                    
                    HStack {
                        CustomTextField(text: $viewModel.firstName, type: .firstName)
                            .outlined()
                        CustomTextField(text: $viewModel.lastName, type: .lastName)
                            .outlined()
                    }
                    
                    CustomTextField(text: $viewModel.employeeNumber, type: .employeeNumber)
                        .outlined()
                    CustomTextField(text: $viewModel.phoneNumber, type: .phoneNumber)
                        .outlined()
                }
                .padding(.horizontal)
                .disabled(viewModel.saveState == .saving)
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
                        .overlay {
                            if viewModel.saveState == .saving {
                                ProgressView()
                                    .tint(.white)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .background {
                                        RoundedRectangle(cornerRadius: 10)
                                            .foregroundStyle(.blue)
                                    }
                            }
                        }
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
            Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK"), action: {
                if viewModel.saveState == .saved {
                    self.isEditing = false
                }
            }))
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
                shouldReloadUserData = true
            default:
                break
            }
        }
        .onTapGesture {
            self.hideKeyboard()
        }
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
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
                EditUserProfileView(userData: userData, isEditing: .constant(true), shouldReloadUserData: .constant(false))
            }
        }
    }
}
