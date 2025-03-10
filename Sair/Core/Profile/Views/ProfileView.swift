import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var session: SessionStore
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.backgroundCream.ignoresSafeArea()
                
                if let user = session.user {
                    ScrollView {
                        VStack(spacing: 25) {
                            // Profile avatar and header
                            VStack(spacing: 10) {
                                ZStack {
                                    Circle()
                                        .fill(Color.primaryGreen.opacity(0.1))
                                        .frame(width: 120, height: 120)
                                    
                                    Text(user.gender.emoji)
                                        .font(.system(size: 70))
                                }
                                
                                Text(user.username ?? "User")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primaryGreen)
                                
                                Text(user.email ?? "")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.top, 20)
                            
                            // Stats cards with improved design
                            VStack(spacing: 15) {
                                Text("Your Adventure Stats")
                                    .font(.headline)
                                    .foregroundColor(.primaryGreen)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal)
                                
                                HStack(spacing: 15) {
                                    StatCard(title: "Points", value: "\(user.totalPoints)", icon: "star.fill")
                                    StatCard(title: "Completed", value: "\(user.questsCompleted)", icon: "flag.fill")
                                    StatCard(title: "Created", value: "\(user.questsCreated)", icon: "plus.circle.fill")
                                }
                            }
                            .padding(.horizontal)
                            
                            // Achievements section (placeholder)
                            VStack(spacing: 15) {
                                Text("Achievements")
                                    .font(.headline)
                                    .foregroundColor(.primaryGreen)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal)
                                
                                AchievementCard(
                                    title: "New Explorer",
                                    description: "Join the Sair community",
                                    isUnlocked: true
                                )
                                
                                AchievementCard(
                                    title: "Quest Creator",
                                    description: "Create your first quest",
                                    isUnlocked: false
                                )
                                
                                AchievementCard(
                                    title: "Adventurer",
                                    description: "Complete 5 quests",
                                    isUnlocked: false
                                )
                            }
                            .padding(.horizontal)
                            
                            Spacer(minLength: 50)
                            
                            // Sign out button with improved styling
                            Button(action: {
                                session.signOut()
                            }) {
                                HStack {
                                    Image(systemName: "rectangle.portrait.and.arrow.right")
                                    Text("Sign Out")
                                }
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red.opacity(0.8))
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            }
                            .padding(.horizontal, 30)
                            .padding(.bottom, 30)
                        }
                    }
                } else {
                    VStack {
                        ProgressView()
                        Text("Loading profile...")
                            .foregroundColor(.secondary)
                            .padding()
                    }
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Profile")
                        .font(.headline)
                        .foregroundColor(.primaryGreen)
                }
            }
        }
    }
}

struct StatCard: View {
    var title: String
    var value: String
    var icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundColor(.primaryGreen)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.primaryGreen)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 15)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct AchievementCard: View {
    var title: String
    var description: String
    var isUnlocked: Bool
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: isUnlocked ? "checkmark.circle.fill" : "circle")
                .font(.title2)
                .foregroundColor(isUnlocked ? .primaryGreen : .gray)
            
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(isUnlocked ? .primaryGreen : .gray)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}
