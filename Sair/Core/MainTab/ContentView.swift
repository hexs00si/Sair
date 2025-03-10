//
//  ContentView.swift
//  Sair
//
//  Created by Shravan Rajput on 10/03/25.
//
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var session: SessionStore
    
    var body: some View {
        Group {
            if session.isLoading {
                LoadingView()
            } else if session.isLoggedIn {
                MainTabView()
            } else {
                LoginView()
            }
        }
    }
}


struct LoadingView: View {
    var body: some View {
        ZStack {
            Color.backgroundCream.ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image(systemName: "figure.hiking")
                    .font(.system(size: 60))
                    .foregroundColor(.primaryGreen)
                
                Text("Sair")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.primaryGreen)
                
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .primaryGreen))
                    .scaleEffect(1.5)
                    .padding()
                
                Text("Preparing your adventure...")
                    .foregroundColor(.primaryGreen.opacity(0.8))
            }
        }
    }
}
