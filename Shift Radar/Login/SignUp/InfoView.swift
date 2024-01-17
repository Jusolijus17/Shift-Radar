//
//  InfoView.swift
//  Shift Radar
//
//  Created by Justin Lefrançois on 2023-10-26.
//

import SwiftUI

struct InfoView: View {
    @Binding var password: String
    @Binding var confirmPassword: String
    @EnvironmentObject var userData: UserData
    
    var body: some View {
        VStack {
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
                            .stroke(Color.accentColor.opacity(0.5), lineWidth: 1)
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
                        .stroke(Color.accentColor.opacity(0.5), lineWidth: 1)
                }
            }
        }
        .padding()
    }
}

struct PictureView: View {
    @Binding var showSheet: Bool
    @Binding var profilePicture: UIImage?
    
    var body: some View {
        Button(action: {
            showSheet = true
        }, label: {
            if let profileImage = profilePicture {
                Image(uiImage: profileImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 140, height: 140)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .shadow(radius: 10)
            } else {
                RoundedRectangle(cornerRadius: 14)
                    .fill(.white)
                    .stroke(Color.accentColor.opacity(0.5), lineWidth: 1)
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
    }
}

#Preview {
    SignUpView()
}
