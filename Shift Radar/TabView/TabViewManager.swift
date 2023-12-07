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
    @State var selectedTab = 0
    @State private var showSettings = false
    
    @EnvironmentObject var appModel: AppViewModel
    
    var body: some View {
        NavigationView {
            TabView(selection: $selectedTab) {
                Group {
                    OfferShiftViewController()
                        .tabItem {
                            Image(systemName: "gift")
                            Text("Offer")
                        }
                        .tag(0)
                    
                    PickupShiftView()
                        .tabItem {
                            Image(systemName: "hand.raised")
                            Text("Pickup")
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
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.background)
            }
            .navigationTitle("Shift Radar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        // show profile
                    } label: {
                        ProfileImageView(userData: appModel.userData)
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
                            .foregroundColor(Color.accent)
                            .clipShape(Circle())
                    }
                }
            }
            .toolbarBackground(.accent, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
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

struct ProfileImageView: View {
    var userData: UserData?
    
    var body: some View {
        Group {
            if let urlString = userData?.profileImageUrl, let url = URL(string: urlString) {
                AsyncImage(url: url) { image in
                    image.resizable()
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 35, height: 35)
                .clipShape(Circle())
            } else {
                Image(systemName: "person")
                    .frame(width: 35, height: 35)
                    .background(Color.white)
                    .clipShape(Circle())
            }
        }
    }
}

struct TabViewManager_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper(selectedTab: 0)
    }
    
    struct PreviewWrapper: View {
        @State private var selectedTab: Int
        
        init(selectedTab: Int) {
            self._selectedTab = State(initialValue: selectedTab)
        }
        
        var body: some View {
            TabViewManager(selectedTab: selectedTab)
        }
    }
}
