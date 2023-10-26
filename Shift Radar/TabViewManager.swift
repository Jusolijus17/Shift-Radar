//
//  HomePage.swift
//  Shift Radar
//
//  Created by Justin Lefrançois on 2023-10-24.
//

import SwiftUI
import UIKit
import FirebaseAuth

struct TabViewManager: View {
    @State private var selectedTab = 0
    @State private var showSettings = false
    
    @EnvironmentObject var userData: UserData
    
    var body: some View {
        NavigationView {
            TabView(selection: $selectedTab) {
                Group {
                    PickupShiftView()
                        .tabItem {
                            Image(systemName: "hand.raised")
                            Text("Pickup")
                        }
                        .tag(0)
                    
                    OfferShiftView()
                        .tabItem {
                            Image(systemName: "gift")
                            Text("Offer")
                        }
                        .tag(1)
                    
                    RequestShiftView()
                        .tabItem {
                            Image(systemName: "bell.fill")
                            Text("Request")
                        }
                        .tag(2)
                    
                    StaffView()
                        .tabItem {
                            Image(systemName: "person.fill")
                            Text("Staff")
                        }
                        .tag(3)
                }
                .toolbarBackground(Color.accentColor2, for: .tabBar)
                .toolbarBackground(.visible, for: .tabBar)
                .toolbarColorScheme(.dark, for: .tabBar)
            }
            .navigationTitle("Shift Radar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if let profileImage = userData.profileImage {
                        Button {
                            // show profile
                        } label: {
                            Image(uiImage: profileImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 35, height: 35)
                                .clipShape(Circle())
                        }
                    } else {
                        Button {
                            // show profile
                        } label: {
                            Image(systemName: "person")
                                .frame(width: 35, height: 35)
                                .background {
                                    Circle()
                                        .fill(.white)
                                }
                        }
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showSettings.toggle()
                    } label: {
                        Image(systemName: "line.horizontal.3")
                            .font(.system(size: 16, design: .rounded))
                            .frame(width: 35, height: 35)
                            .background(Color.white)
                            .foregroundColor(Color.accentColor)
                            .clipShape(Circle())
                    }
                }
            }
            .toolbarBackground(Color.accentColor, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .sheet(isPresented: $showSettings, content: {
            Button {
                logout()
            } label: {
                Text("Logout")
            }

        })
    }
    
    func logout() {
        let firebaseAuth = Auth.auth()
        do {
          try firebaseAuth.signOut()
        } catch let signOutError as NSError {
          print("Error signing out: %@", signOutError)
        }
    }
}

struct TabViewManager_Previews: PreviewProvider {
    static var previews: some View {
        let userData = UserData()
        
        TabViewManager()
            .environmentObject(userData)
            .onAppear(perform: {
                userData.profileImage = UIImage(named: "preview1")
            })
    }
}