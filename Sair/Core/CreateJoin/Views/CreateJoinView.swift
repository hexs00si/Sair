import SwiftUI
import MapplsMap
import FirebaseFirestore
import FirebaseAuth

struct CreateJoinView: View {
    @State private var showQuestCreation = false
    @State private var userQuests: [Quest] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var selectedQuest: Quest? = nil
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.backgroundCream.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Create quest card
                        ActionCard(
                            title: "Create a Quest",
                            description: "Design your own adventure for others to enjoy",
                            icon: "plus.circle.fill",
                            action: {
                                showQuestCreation = true
                            }
                        )
                        
                        // Community quests card (upcoming feature)
                        ActionCard(
                            title: "Community Quests",
                            description: "Discover popular quests created by the community (Coming Soon)",
                            icon: "globe",
                            action: {
                                // Handle community quests action
                            }
                        )
                        .opacity(0.5) // Dim to indicate it's not available yet
                        
                        // User's created quests
                        if isLoading {
                            ProgressView()
                                .padding()
                        } else if !userQuests.isEmpty {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Your Quests")
                                    .font(.headline)
                                    .foregroundColor(.primaryGreen)
                                    .padding(.horizontal)
                                
                                ForEach(userQuests) { quest in
                                    UserQuestCard(quest: quest) // Renamed to UserQuestCard
                                        .padding(.horizontal)
                                        .onTapGesture {
                                            selectedQuest = quest
                                        }
                                        .contextMenu {
                                            Button(role: .destructive) {
                                                deleteQuest(quest)
                                            } label: {
                                                Label("Delete", systemImage: "trash")
                                            }
                                        }
                                }
                            }
                        } else {
                            Text("You haven't created any quests yet.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .padding()
                        }
                        
                        Spacer()
                    }
                    .padding(.top, 20)
                }
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
            .sheet(isPresented: $showQuestCreation) {
                QuestCreationView()
            }
            .sheet(item: $selectedQuest) { quest in
                QuestDetailView(quest: quest)
            }
            .onAppear {
                fetchUserQuests()
            }
        }
    }
    
    // Fetch quests created by the current user
    func fetchUserQuests() {
        guard let userID = Auth.auth().currentUser?.uid else {
            errorMessage = "User not logged in"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        let db = Firestore.firestore()
        db.collection("quests")
            .whereField("creatorID", isEqualTo: userID)
            .getDocuments { snapshot, error in
                DispatchQueue.main.async {
                    isLoading = false
                    
                    if let error = error {
                        errorMessage = "Failed to fetch quests: \(error.localizedDescription)"
                        return
                    }
                    
                    if let documents = snapshot?.documents {
                        userQuests = documents.compactMap { document in
                            try? document.data(as: Quest.self)
                        }
                    }
                }
            }
    }
    
    // Delete a quest
    func deleteQuest(_ quest: Quest) {
        guard let userID = Auth.auth().currentUser?.uid else {
            errorMessage = "User not logged in"
            return
        }
        
        let db = Firestore.firestore()
        db.collection("quests").document(quest.id).delete { error in
            if let error = error {
                errorMessage = "Failed to delete quest: \(error.localizedDescription)"
            } else {
                // Remove the quest from the local list
                userQuests.removeAll { $0.id == quest.id }
            }
        }
    }
}

// MARK: - User Quest Card (Renamed from QuestCard)
struct UserQuestCard: View {
    var quest: Quest
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(quest.title)
                .font(.headline)
                .foregroundColor(.primaryGreen)
            
            Text(quest.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            HStack {
                Text("Difficulty: \(quest.difficulty)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("Points: \(quest.pointsValue)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Quest Detail View
struct QuestDetailView: View {
    var quest: Quest
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(quest.title)
                    .font(.largeTitle)
                    .foregroundColor(.primaryGreen)
                
                Text(quest.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Details")
                        .font(.headline)
                        .foregroundColor(.primaryGreen)
                    
                    HStack {
                        Text("Difficulty:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("\(quest.difficulty)")
                            .font(.subheadline)
                            .foregroundColor(.primary)
                    }
                    
                    HStack {
                        Text("Points:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("\(quest.pointsValue)")
                            .font(.subheadline)
                            .foregroundColor(.primary)
                    }
                    
                    HStack {
                        Text("Category:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text(quest.category)
                            .font(.subheadline)
                            .foregroundColor(.primary)
                    }
                }
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Quest Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Action Card
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
