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
                
                TextField("Email", text: $email)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8.0)

                SecureField("Password", text: $password)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8.0)

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
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8.0)
            }
            .padding()
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
