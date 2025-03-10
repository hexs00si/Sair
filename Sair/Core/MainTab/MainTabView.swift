//
//  MainTabView.swift
//  Sair
//
//  Created by Shravan Rajput on 10/03/25.
//
import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var session: SessionStore
    
    var body: some View {
        TabView {
            ExploreView()
                .tabItem {
                    Label("Explore", systemImage: "map.fill")
                }
            
            CreateJoinView()
                .tabItem {
                    Label("Create", systemImage: "plus.circle.fill")
                }
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
        }
        .accentColor(.primaryGreen)
        .onAppear {
            // Customize tab bar appearance
            let appearance = UITabBarAppearance()
            appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterial)
            appearance.backgroundColor = UIColor(Color.backgroundCream.opacity(0.5))
            
            // Use the appearance everywhere
            UITabBar.appearance().standardAppearance = appearance
            if #available(iOS 15.0, *) {
                UITabBar.appearance().scrollEdgeAppearance = appearance
            }
            
            print("DEBUG: Main Tab View appeared")
        }
    }
}
