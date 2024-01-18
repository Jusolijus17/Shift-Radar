//
//  LoginManager.swift
//  Shift Radar
//
//  Created by Justin Lefrançois on 2023-10-24.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

class LoginManagerData: ObservableObject {
    @Published var isCreatingAccount: Bool = false
    @Published var isUserLoggedIn: Bool = (Auth.auth().currentUser != nil)
}

struct LoginManager: View {
    @StateObject private var loginManagerData = LoginManagerData()
    @EnvironmentObject var appModel: AppViewModel
    @State var authHandler: AuthStateDidChangeListenerHandle?

    var body: some View {
        Group {
            if loginManagerData.isUserLoggedIn {
                TabViewManager()
            } else {
                SplashScreen()
                    .environmentObject(loginManagerData)
            }
        }
        .onAppear {
            attachAuthListener()
        }
        .onDisappear {
            detachAuthListener()
        }
        .onChange(of: loginManagerData.isCreatingAccount) { oldValue, newValue in
            if newValue == false {
                verifyConnection()
            }
        }
    }
    
    private func attachAuthListener() {
        authHandler = Auth.auth().addStateDidChangeListener { (auth, user) in
            if !loginManagerData.isCreatingAccount {
                verifyConnection()
            }
        }
    }
    
    private func verifyConnection() {
        withAnimation {
            let user = Auth.auth().currentUser
            self.loginManagerData.isUserLoggedIn = (user != nil)
            if self.loginManagerData.isUserLoggedIn {
                self.appModel.loadUserData()
            }
        }
    }
    
    private func detachAuthListener() {
        if let authHandler = authHandler {
            Auth.auth().removeStateDidChangeListener(authHandler)
        }
    }
}

#Preview {
    LoginManager()
        .environmentObject(AppViewModel())
}
