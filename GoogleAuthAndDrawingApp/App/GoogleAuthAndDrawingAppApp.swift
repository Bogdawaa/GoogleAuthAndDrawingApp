//
//  GoogleAuthAndDrawingAppApp.swift
//  GoogleAuthAndDrawingApp
//
//  Created by Bogdan Fartdinov on 15.05.2025.
//

import SwiftUI

@main
struct GoogleAuthAndDrawingAppApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @ObservedObject var router = Router.shared
    @StateObject var sessionManager = SessionManager()
    
    var body: some Scene {
        WindowGroup {
            if sessionManager.isLoggedIn {
                MainView()
            }
            else {
                AuthView(router: router)
            }
        }
    }
}
