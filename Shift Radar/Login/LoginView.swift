//
//  ContentView.swift
//  Shift Radar
//
//  Created by Justin Lefrançois on 2023-10-24.
//

import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var error: String?

    var body: some View {
        NavigationView {
            VStack {
                Text("Shift Radar")
                    .font(.largeTitle)
                
                Spacer()
                
                VStack(spacing: 18) {
                    CustomTextField(text: $email, placeholder: "Email", systemName: "envelope")
                        .padding()
                        .background {
                            RoundedRectangle(cornerRadius: 10.0)
                                .fill(.white)
                                .stroke(Color.accentColor.opacity(0.5), lineWidth: 1)
                        }
                    
                    CustomSecureField(text: $password, placeholder: "Password", systemName: "lock")
                        .padding()
                        .background {
                            RoundedRectangle(cornerRadius: 10.0)
                                .fill(.white)
                                .stroke(Color.accentColor.opacity(0.5), lineWidth: 1)
                        }
                    
                    Button {
                        
                    } label: {
                        Text("Forgot your password?")
                    }


                }

                Spacer()
                
                if let error = error {
                    Text(error)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.red)
                        .padding(.bottom)
                }

                NavigationLink("No account? Sign up!", destination: {
                    SignUpView()
                        .navigationBarBackButtonHidden()
                })
                
                Button {
                    login()
                } label: {
                    Text("Login")
                        .frame(maxWidth: .infinity)
                        .fontWeight(.semibold)
                        .padding()
                        .foregroundColor(.white)
                        .background {
                            RoundedRectangle(cornerRadius: 25.0)
                                .fill(Color.accentColor)
                                .padding(.horizontal)
                        }
                }
                
            }
            .padding()
            .background {
                VStack {
                    Spacer()
                    Circle()
                        .fill(Color.accentColor2)
                        .frame(width: 1100, height: 1100)
                        .offset(y: 700)
                }
                .background(Color.background)
                .ignoresSafeArea()
            }
        }
    }
    
    func login() {
        Auth.auth().signIn(withEmail: email, password: password) { (authResult, error) in
            if let error = error {
                self.error = error.localizedDescription
                return
            }
        }
    }
}


#Preview {
    LoginView()
}
