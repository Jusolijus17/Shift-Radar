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
                        CustomTextField(text: $userData.firstName, type: .firstName)
                            .outlined()
                        CustomTextField(text: $userData.lastName, type: .lastName)
                            .outlined()
                    }
                }
                
                CustomTextField(text: $userData.email, type: .email)
                    .outlined()
                CustomTextField(text: $userData.employeeNumber, type: .employeeNumber)
                    .outlined()
                CustomTextField(text: $password, type: .password)
                    .outlined()
                CustomTextField(text: $confirmPassword, type: .confirmPassword)
                    .outlined()
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
