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
        MapplsAccountManager.setMapSDKKey("28e91e265006517c59793f26bf3d3901")
        MapplsAccountManager.setRestAPIKey("28e91e265006517c59793f26bf3d3901")
        MapplsAccountManager.setClientId("96dHZVzsAusEUYIs0lYyowEatqMmPwzsepxX2hfxeyP7LhygBOc5l03hclQpITktkE68urOvdKagQ4TxdDgEAQ==")
        MapplsAccountManager.setClientSecret("lrFxI-iSEg-109pzoCFaWKKAHmDGHYkIgcKa5DXIGPWkmHr8ML1cSGD6g4PTkuP5wXIhCcLMJGDHXJImAEJFWrtlGEmng9kx")
        print("DEBUG: Mappls keys configured")
    }
}
