import SwiftUI

struct ExploreView: View {
    var body: some View {
        NavigationView {
            ZStack {
                Color.backgroundCream.ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Placeholder for map
                    ZStack {
                        Rectangle()
                            .fill(Color.white)
                            .cornerRadius(20)
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                        
                        VStack {
                            Image(systemName: "map.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.primaryGreen.opacity(0.3))
                            
                            Text("Map Coming Soon")
                                .font(.headline)
                                .foregroundColor(.primaryGreen)
                                .padding(.top, 5)
                        }
                    }
                    .frame(height: 300)
                    .padding(.horizontal)
                    
                    // Nearby quests section
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Nearby Quests")
                            .font(.headline)
                            .foregroundColor(.primaryGreen)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                ForEach(1...5, id: \.self) { _ in
                                    QuestCard()
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    Spacer()
                }
                .padding(.top)
            }
            .navigationTitle("Explore")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Explore")
                        .font(.headline)
                        .foregroundColor(.primaryGreen)
                }
            }
        }
    }
}

struct QuestCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack(alignment: .topTrailing) {
                Rectangle()
                    .fill(Color.primaryGreen.opacity(0.2))
                    .frame(width: 160, height: 100)
                    .cornerRadius(12)
                
                Text("2.5 km")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.white.opacity(0.9))
                    .cornerRadius(8)
                    .padding(8)
            }
            
            VStack(alignment: .leading, spacing: 5) {
                Text("Heritage Walk")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primaryGreen)
                
                Text("Cultural • 45 min")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack {
                    ForEach(0..<3) { _ in
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.system(size: 10))
                    }
                    ForEach(0..<2) { _ in
                        Image(systemName: "star")
                            .foregroundColor(.yellow)
                            .font(.system(size: 10))
                    }
                }
            }
            .padding(.horizontal, 8)
        }
        .frame(width: 160, height: 170)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 3)
    }
}
