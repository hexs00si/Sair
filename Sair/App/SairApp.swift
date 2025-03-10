//
//  SairApp.swift
//  Sair
//
//  Created by Shravan Rajput on 10/03/25.
//

import SwiftUI
import FirebaseCore
import MapplsAPICore


@main
struct SairApp: App {
    @StateObject private var sessionStore = SessionStore()
    
    init() {
        setupServices()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(sessionStore)
        }
    }
    
    private func setupServices() {
        // Initialize Firebase
        FirebaseApp.configure()
        print("DEBUG: Firebase initialized successfully")
        
        // Initialize MapMyIndia SDK
        MapplsAccountManager.setMapSDKKey("YOUR_MAP_SDK_KEY")
        MapplsAccountManager.setRestAPIKey("YOUR_REST_API_KEY")
        MapplsAccountManager.setClientId("YOUR_CLIENT_ID")
        MapplsAccountManager.setClientSecret("YOUR_CLIENT_SECRET")
        print("DEBUG: Mappls keys configured")
    }
}
