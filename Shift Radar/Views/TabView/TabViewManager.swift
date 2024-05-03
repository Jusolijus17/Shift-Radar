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
    @State private var showProfile = false
    
    @EnvironmentObject var appModel: AppViewModel
    
    var body: some View {
        SideBarStack(sidebarWidth: 75, showSidebar: $showSettings) {
            VStack {
                Spacer()
                Button {
                    
                } label: {
                    Image(systemName: "gear")
                        .foregroundStyle(Color.white)
                        .font(.title)
                        .fontWeight(.semibold)
                        .padding(.bottom)
                }

                Button {
                    logout()
                } label: {
                    Image(systemName: "escape")
                        .font(.title)
                        .fontWeight(.semibold)
                }
            }
        } content: {
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
                        
                        RequestsView()
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
                            self.showProfile = true
                        } label: {
                            ProfileImage(userData: appModel.userData, placeholder: {
                                Image(systemName: "person.fill")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                            })
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            withAnimation {
                                showSettings.toggle()
                            }
                        } label: {
                            Image(systemName: "line.horizontal.3")
                                .font(.title3)
                                .fontWeight(.semibold)
                        }
                    }
                }
                .toolbarBackground(.accent, for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
                .toolbarColorScheme(.dark, for: .navigationBar)
                .sheet(isPresented: $showProfile) {
                    UserProfileView()
                        .environmentObject(appModel.userData ?? UserData.dummyUser())
                }
            }
        }
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
        PreviewWrapper(selectedTab: 0)
    }
    
    struct PreviewWrapper: View {
        @State private var selectedTab: Int
        @StateObject private var appModel = AppViewModel()
        
        init(selectedTab: Int) {
            self._selectedTab = State(initialValue: selectedTab)
            appModel.userData = UserData.dummyUser()
        }
        
        var body: some View {
            TabViewManager(selectedTab: selectedTab)
                .environmentObject(appModel)
        }
    }
}
