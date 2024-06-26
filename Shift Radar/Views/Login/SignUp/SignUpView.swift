//
//  SignUpView.swift
//  Shift Radar
//
//  Created by Justin Lefrançois on 2023-10-24.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

struct SignUpView: View {
    @StateObject private var viewModel = SignUpViewModel()
    
    @State private var image: UIImage?
    @State private var showSheet = false
    
    @Environment(\.presentationMode) var presentationMode
    
    @EnvironmentObject var loginManagerData: LoginManagerData
    
    var body: some View {
        ZStack {
            GeometryReader { geo in
                SemiRoundedRectangle(curveHeight: viewModel.accountCreationState == .success ? 0 : 30)
                    .fill(Color.accentColor2)
                    .frame(height: geo.size.height * viewModel.backgroundHeightMultiplier)
                    .frame(maxHeight: .infinity, alignment: .bottom)
            }
            .background(Color.background)
            .ignoresSafeArea()
            
            ScrollView {
                VStack {
                    viewModel.accountCreationState == .success ? Spacer() : nil
                    PictureView(showSheet: $showSheet, profilePicture: $viewModel.profilePicture)
                        .padding(.top, viewModel.accountCreationState == .emailConfirmation ? 100 : 20)
                    
                    if viewModel.accountCreationState == .emailConfirmation || viewModel.accountCreationState == .success {
                        Text(viewModel.labelText)
                            .foregroundStyle(viewModel.accountCreationState == .success ? Color.white : Color.black)
                            .font(.headline)
                            .padding(.vertical, 22)
                            .transition(.opacity)
                    }
                    if viewModel.accountCreationState == .basicInfo {
                        Spacer()
                        InfoView(password: $viewModel.password, confirmPassword: $viewModel.confirmPassword)
                            .transition(.move(edge: .leading).combined(with: .opacity))
                        Spacer()
                    }
                    
                    if viewModel.accountCreationState == .emailConfirmation {
                        EmailConfirmView()
                    }
                    
                    if let error = viewModel.error {
                        Text(error)
                            .foregroundStyle(.red)
                    }
                    
                    Spacer()
                    
                    if viewModel.accountCreationState == .basicInfo && !viewModel.isLoading {
                        Button("Already have an account? Login.") {
                            presentationMode.wrappedValue.dismiss()
                        }
                        .disabled(viewModel.isLoading)
                    }
                    
                    Button(action: {
                        buttonTap()
                    }, label: {
                        if viewModel.isLoading {
                            ProgressView()
                                .frame(width: 25, height: 25)
                        } else {
                            Text(viewModel.buttonText)
                                .transition(.identity)
                                .frame(maxWidth: .infinity)
                                .fontWeight(.semibold)
                                .foregroundStyle(.white)
                                .padding()
                                .background {
                                    RoundedRectangle(cornerRadius: 25.0)
                                        .fill(Color.accentColor)
                                }
                                .opacity(viewModel.isLoading ? 0.6 : 1)
                                .padding(.horizontal)
                        }
                    })
                    //.disabled(isLoading || accountCreationState == .emailConfirmation)
                    
                }
                .sheet(isPresented: $showSheet) {
                    ImagePicker(sourceType: .photoLibrary, selectedImage: self.$image)
                        .onDisappear(perform: {
                            viewModel.profilePicture = image
                        })
                        .ignoresSafeArea()
                }
                .environmentObject(viewModel.userData)
            }
        }
    }
    
    func buttonTap() {
        switch viewModel.accountCreationState {
        case .basicInfo:
            loginManagerData.isCreatingAccount = true
            viewModel.createAccount()
        case .emailConfirmation:
            viewModel.verifyEmail()
        case .success:
            loginManagerData.isCreatingAccount = false
            return
        }
    }
}

struct SemiRoundedRectangle: Shape {
    var curveHeight: CGFloat
    
    var animatableData: CGFloat {
        get { curveHeight }
        set { curveHeight = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        let width = rect.size.width
        let height = rect.size.height
        let controlPoint = CGPoint(x: width / 2, y: -curveHeight)
        
        return Path { path in
            path.move(to: CGPoint(x: 0, y: curveHeight))
            path.addQuadCurve(to: CGPoint(x: width, y: curveHeight), control: controlPoint)
            path.addLine(to: CGPoint(x: width, y: height))
            path.addLine(to: CGPoint(x: 0, y: height))
            path.closeSubpath()
        }
    }
}


#Preview {
    SignUpView()
        .environmentObject(LoginManagerData())
}
