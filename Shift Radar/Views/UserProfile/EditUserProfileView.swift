//
//  EditProfileView.swift
//  Shift Radar
//
//  Created by Justin Lefrançois on 2024-05-02.
//

import SwiftUI

struct EditUserProfileView: View {
    @EnvironmentObject var userData: UserData
    @State private var phoneNumber: String = ""
    
    var body: some View {
        VStack {
            VStack(spacing: 20) {
                ProfileImage(userData: userData, placeholder: {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                })
                .editable()
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top)
                
                HStack {
                    CustomTextField(text: $userData.firstName, placeholder: "First name", systemName: "person.fill")
                        .outlined()
                    CustomTextField(text: $userData.lastName, placeholder: "Last name", systemName: "person")
                        .outlined()
                }

                CustomTextField(text: $userData.email, placeholder: "Email", systemName: "envelope")
                    .outlined()
                
                EmployeeNumberField(number: $userData.employeeNumber)
                    .outlined()
                
                CustomTextField(text: $phoneNumber, placeholder: "Add phone number", systemName: "phone")
                    .outlined()
                
            }
            .padding(.horizontal)
            
            Spacer()
            
            HStack {
                Button {
                    
                } label: {
                    Text("Save")
                        .foregroundColor(.white)
                        .padding()
                        .bold()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                        .padding(.leading)
                }
                
                Button {
                    
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
                        .padding(.trailing)
                }
            }
        }
        .navigationTitle("Edit profile")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.background)
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
                EditUserProfileView()
                    .environmentObject(userData)
            }
        }
    }
}
