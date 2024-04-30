//
//  SplashScreen.swift
//  Shift Radar
//
//  Created by Justin Lefrançois on 2024-01-17.
//

import SwiftUI

struct SplashScreen: View {
    let images = ["splash1", "splash2", "splash3", "splash4", "splash5", "splash6", "splash7"]
    @State private var currentIndex = 0
    @State private var timer: Timer?
    
    var body: some View {
        NavigationView {
            ZStack {
                Image(images[currentIndex])
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .onAppear {
                        timer?.invalidate()
                        timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { timer in
                            withAnimation(.easeInOut(duration: 1)) {
                                currentIndex = (currentIndex + 1) % images.count
                            }
                        }
                    }
                    .onDisappear {
                        timer?.invalidate()
                    }
                    .overlay {
                        Color.black.opacity(0.5)
                            .ignoresSafeArea()
                    }
                VStack {
                    VStack(alignment: .leading) {
                        Text("Welcome \nto Shift-Radar")
                            .font(.system(size: 35))
                            .foregroundStyle(.white)
                            .fontWeight(.bold)
                            .padding(.top, 75)
                        Text("Login or create an account to start.")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.5))
                            .fontWeight(.semibold)
                    }
                    Spacer()
                    NavigationLink {
                        LoginView()
                    } label: {
                        Text("Login now")
                            .foregroundStyle(.white)
                            .fontWeight(.semibold)
                            .padding(.vertical)
                            .frame(width: 300)
                            .background {
                                RoundedRectangle(cornerRadius: 25.0)
                                    .foregroundStyle(.accent)
                            }
                            .padding(.bottom)
                    }
                    
                    NavigationLink {
                        SignUpView()
                    } label: {
                        Text("Sign Up")
                            .foregroundStyle(.white)
                            .fontWeight(.semibold)
                            .padding(.vertical)
                            .frame(width: 300)
                            .background {
                                RoundedRectangle(cornerRadius: 25.0)
                                    .stroke()
                                    .foregroundStyle(.accent)
                            }
                            .padding(.bottom, 50)
                    }
                }
            }
        }
    }
}

#Preview {
    SplashScreen()
}
