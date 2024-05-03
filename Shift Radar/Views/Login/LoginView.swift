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
            ZStack {
                BackgroundView(heightMultiplier: 0.3, radiusFactor: 1.5)
                    .ignoresSafeArea(edges: .all)
                VStack {
                    Text("Login")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    VStack(spacing: 18) {
                        CustomTextField(text: $email, placeholder: "Email", systemName: "envelope")
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
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
            }
        }
        .onTapGesture {
            self.hideKeyboard()
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
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct BackgroundView: View {
    @State var heightMultiplier: CGFloat
    @State var radiusFactor: CGFloat
    
    var body: some View {
        GeometryReader { geo in
            VStack {
                Spacer()
                RoundedTopRectangle(radiusFactor: radiusFactor)
                    .fill(.accentColor2)
                    .frame(height: geo.size.height * heightMultiplier)
            }
            .background(Color.background)
            .ignoresSafeArea()
        }
    }
}

struct RoundedTopRectangle: Shape {
    var radiusFactor: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()

        let radius = rect.width * radiusFactor // Ajustez le rayon selon vos besoins

        // Commencer en bas à gauche
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))

        // Ligne vers le bas à droite
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))

        // Ligne vers le haut à droite
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + radius))

        // Arc arrondi pour le haut
        path.addArc(center: CGPoint(x: rect.midX, y: rect.minY + radius), radius: radius,
                    startAngle: Angle(degrees: 0), endAngle: Angle(degrees: 180), clockwise: true)

        // Ligne vers le bas à gauche
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + radius))

        // Fermer le Path
        path.closeSubpath()

        return path
    }
}


#Preview {
    LoginView()
}
