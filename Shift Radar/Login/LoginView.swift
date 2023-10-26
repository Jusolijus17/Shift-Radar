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
                                .stroke(Color(hex: "#D7EAE7"), lineWidth: 1.5)
                        }
                    
                    CustomSecureField(text: $password, placeholder: "Password", systemName: "lock")
                        .padding()
                        .background {
                            RoundedRectangle(cornerRadius: 10.0)
                                .fill(.white)
                                .stroke(Color(hex: "#D7EAE7"), lineWidth: 1.5)
                        }
                    
                    Button {
                        
                    } label: {
                        Text("Forgot your password?")
                    }


                }

                Spacer()
                
                if let error = error {
                    Text(error)
                        .foregroundStyle(.red)
                }

                NavigationLink("No account? Sign up!", destination: {
                    SignUpView()
                        .navigationBarBackButtonHidden()
                })
                
                Button("Login") {
                    login()
                }
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
            .padding()
            .background {
                VStack {
                    Spacer()
                    Circle()
                        .fill(Color.accentColor2)
                        .frame(width: 1100, height: 1100)
                        .offset(y: 700)
                }
                .background(Color(hex: "#F2F2F2"))
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
