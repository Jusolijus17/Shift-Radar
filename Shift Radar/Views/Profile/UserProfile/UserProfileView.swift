//
//  ProfileView.swift
//  Shift Radar
//
//  Created by Justin Lefrançois on 2024-05-02.
//

import SwiftUI

struct UserProfileView: View {
    @EnvironmentObject var appModel: AppViewModel
    @State private var isEditing = false
    @State private var shouldRelaodUserData = false
    @State private var profileImage: UIImage?
    
    var body: some View {
        NavigationStack {
            if let userData = appModel.userData {
                VStack {
                    VStack(alignment: .leading, spacing: 20) {
                        HStack {
                            ProfileImage(
                                image: $profileImage,
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
                            .onAppear {
                                self.profileImage = userData.profileImage
                            }
                            .onChange(of: userData.profileImage) {
                                self.profileImage = userData.profileImage
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
                        isEditing = true
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
                    
                    Button(action: {
                        // Action to delete account
                    }) {
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
                .navigationDestination(isPresented: $isEditing) {
                    EditUserProfileView(userData: userData, isEditing: $isEditing, shouldReloadUserData: $shouldRelaodUserData)
                        .onDisappear {
                            if shouldRelaodUserData {
                                self.appModel.loadUserData()
                            }
                        }
                }
            } else {
                Text("Error loading user profile")
                    .foregroundStyle(.secondary)
                    .navigationTitle("Profile")
                    .navigationBarTitleDisplayMode(.inline)
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
