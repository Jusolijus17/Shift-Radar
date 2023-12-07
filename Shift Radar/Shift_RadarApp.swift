//
//  Shift_RadarApp.swift
//  Shift Radar
//
//  Created by Justin Lefrançois on 2023-10-24.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}

@main
struct Shift_RadarApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var appModel = AppViewModel()
    var body: some Scene {
        WindowGroup {
            LoginManager()
        }
        .environmentObject(appModel)
    }
}
