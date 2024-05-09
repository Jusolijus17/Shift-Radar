//
//  ProfileView.swift
//  Shift Radar
//
//  Created by Justin Lefrançois on 2024-05-02.
//

import SwiftUI

struct UserProfileView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appModel: AppViewModel
    @ObservedObject private var viewModel = UserProfileViewModel()
    
    var body: some View {
        NavigationStack {
            if let userData = appModel.userData {
                VStack {
                    VStack(alignment: .leading, spacing: 20) {
                        HStack {
                            ProfileImage(
                                image: $viewModel.profileImage,
                                width: 100,
                                height: 100,
                                placeholder: {
                                    Image(systemName: "person.crop.circle.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 100, height: 100)
                                        .clipShape(Circle())
                                }
                            )
                            .expandable()
                            .onAppear {
                                viewModel.profileImage = userData.profileImage
                            }
                            .onChange(of: userData.profileImage) {
                                viewModel.profileImage = userData.profileImage
                            }
                            
                            VStack(alignment: .leading) {
                                Text("\(userData.firstName) \(userData.lastName)")
                                    .font(.title)
                                    .fontWeight(.bold)
                                
                                HStack(spacing: 0) {
                                    Text("Employee #: ")
                                    Text("\(userData.employeeNumber)")
                                        .bold()
                                }
                                .foregroundStyle(.accent)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        
                        Divider()
                        
                        VStack(alignment: .leading) {
                            ProfileDetailRow(label: "Email", value: userData.email)
                                .padding(.bottom)
                            if let phoneNumber = userData.phoneNumber, phoneNumber != "" {
                                ProfileDetailRow(label: "Phone number", value: phoneNumber)
                                    .padding(.bottom)
                            }
                            if let creationDate = userData.creationDate {
                                ProfileDetailRow(label: "Account creation date", value: "\(creationDate.formatted(date: .long, time: .omitted))")
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    Button {
                        viewModel.isEditing = true
                    } label: {
                        HStack {
                            Text("Edit info")
                            Image(systemName: "pencil")
                        }
                        .foregroundColor(.white)
                        .padding()
                        .bold()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                        .padding(.horizontal)
                    }
                    
                    Button {
                        viewModel.showingDeleteAlert = true
                    } label: {
                        Text("Delete account")
                            .foregroundColor(.red)
                            .bold()
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background {
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.red, lineWidth: 2)
                            }
                            .padding(.horizontal)
                    }
                }
                .navigationTitle("Profile")
                .navigationBarTitleDisplayMode(.inline)
                .background(Color.background)
                .navigationDestination(isPresented: $viewModel.isEditing) {
                    EditUserProfileView(userData: userData, isEditing: $viewModel.isEditing, shouldReloadUserData: $viewModel.shouldRelaodUserData)
                        .onDisappear {
                            if viewModel.shouldRelaodUserData {
                                self.appModel.loadUserData()
                                viewModel.shouldRelaodUserData = false
                            }
                        }
                }
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            dismiss()
                        } label: {
                            Text("Close")
                        }
                    }
                }
                .alert("Confirm Account Deletion", isPresented: $viewModel.showingDeleteAlert, actions: {
                    Button("Delete", role: .destructive) {
                        viewModel.deleteAccount()
                    }
                    Button("Cancel", role: .cancel) {}
                }, message: {
                    Text("Are you sure you want to permanently delete your account?")
                })
                .overlay {
                    if viewModel.isDeletingAccount {
                        ZStack {
                            Color.black.opacity(0.5)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .ignoresSafeArea()
                            ProgressView()
                                .scaleEffect(1.5)
                        }
                    }
                }
                .disabled(viewModel.isDeletingAccount)
            } else {
                Text("Error loading user profile")
                    .foregroundStyle(.secondary)
                    .navigationTitle("Profile")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Button {
                                dismiss()
                            } label: {
                                Text("Close")
                            }
                        }
                    }
            }
        }
    }
}

struct ProfileDetailRow: View {
    var label: String
    var value: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
            Text(value)
                .fontWeight(.semibold)
        }
    }
}

struct UserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper()
    }
    
    struct PreviewWrapper: View {
        @State private var appModel = AppViewModel()
        
        init() {
            appModel.userData = UserData.dummyUser()
        }
        
        var body: some View {
            UserProfileView()
                .environmentObject(appModel)
        }
    }
}
