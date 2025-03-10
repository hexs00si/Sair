// Sair/Core/CreateJoin/Views/CreateJoinView.swift
import SwiftUI

struct CreateJoinView: View {
    var body: some View {
        NavigationView {
            ZStack {
                Color.backgroundCream.ignoresSafeArea()
                
                VStack(spacing: 30) {
                    // Create quest card
                    ActionCard(
                        title: "Create a Quest",
                        description: "Design your own adventure for others to enjoy",
                        icon: "plus.circle.fill",
                        action: {
                            // Create quest action
                        }
                    )
                    
                    // Join quest card
                    ActionCard(
                        title: "Join a Quest",
                        description: "Find a quest by code or from your friends",
                        icon: "person.2.fill",
                        action: {
                            // Join quest action
                        }
                    )
                    
                    // Community quests card
                    ActionCard(
                        title: "Community Quests",
                        description: "Discover popular quests created by the community",
                        icon: "globe",
                        action: {
                            // Community quests action
                        }
                    )
                    
                    Spacer()
                }
                .padding(.top, 20)
                .padding(.horizontal)
            }
            .navigationTitle("Create & Join")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Create & Join")
                        .font(.headline)
                        .foregroundColor(.primaryGreen)
                }
            }
        }
    }
}

struct ActionCard: View {
    var title: String
    var description: String
    var icon: String
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 20) {
                Image(systemName: icon)
                    .font(.system(size: 30))
                    .foregroundColor(.primaryGreen)
                    .frame(width: 60, height: 60)
                    .background(Color.primaryGreen.opacity(0.1))
                    .cornerRadius(12)
                
                VStack(alignment: .leading, spacing: 5) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primaryGreen)
                    
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.primaryGreen)
                    .padding(.trailing, 5)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
    }
}
