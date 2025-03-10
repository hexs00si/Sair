import SwiftUI
import MapplsMap
import CoreLocation

struct ExploreView: View {
    @StateObject private var weatherService = WeatherService()
    @StateObject private var locationManager = LocationViewModel()
    @State private var mapView: MapplsMapView?
    @State private var mapLoaded = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.backgroundCream.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Greeting card with gradient
                        VStack(alignment: .leading, spacing: 6) {
                            Text(weatherService.getTimeBasedGreeting())
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text(weatherService.getTimeBasedSuggestion())
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.9))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 16)
                        .padding(.horizontal, 20)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.primaryGreen, Color.primaryGreen.opacity(0.8)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
                        .padding(.horizontal)
                        
                        // Exploration tips card
                        HStack(spacing: 15) {
                            Image(systemName: "map")
                                .font(.title2)
                                .foregroundColor(.primaryGreen)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Exploration Tips")
                                    .font(.headline)
                                    .foregroundColor(.primaryGreen)
                                
                                Text("Tap quests to see details, and use the location button to center the map on your position.")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .lineLimit(2)
                            }
                            
                            Spacer()
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                        .padding(.horizontal)
                        
                        // Map view
                        ZStack {
                            MapViewContainer(mapView: $mapView, onMapLoaded: {
                                mapLoaded = true
                            })
                            .frame(height: 250)
                            .cornerRadius(16)
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 3)
                            
                            // Map loading indicator
                            if !mapLoaded {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .primaryGreen))
                                    .scaleEffect(1.2)
                                    .frame(width: 50, height: 50)
                                    .background(Color.white.opacity(0.8))
                                    .cornerRadius(10)
                            }
                            
                            // Location button
                            VStack {
                                Spacer()
                                HStack {
                                    Spacer()
                                    Button(action: {
                                        if let userLocation = locationManager.userLocation {
                                            mapView?.setCenter(userLocation.coordinate, zoomLevel: 15, animated: true)
                                        }
                                    }) {
                                        Image(systemName: "location.fill")
                                            .foregroundColor(.primaryGreen)
                                            .padding(12)
                                            .background(Color.white)
                                            .clipShape(Circle())
                                            .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
                                    }
                                    .padding(.trailing, 16)
                                    .padding(.bottom, 16)
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        // Nearby quests section
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Quests For You")
                                .font(.headline)
                                .foregroundColor(.primaryGreen)
                                .padding(.horizontal)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 15) {
                                    ForEach(0..<3) { _ in
                                        QuestCard()
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        
                        // Popular quests
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Popular Nearby")
                                .font(.headline)
                                .foregroundColor(.primaryGreen)
                                .padding(.horizontal)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 15) {
                                    ForEach(0..<3) { _ in
                                        QuestCard()
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        
                        Spacer(minLength: 20)
                    }
                    .padding(.top)
                }
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
            .onAppear {
                // Initialize MapplsMap
                initializeMapplsMap()
                
                // Request location
                locationManager.requestLocation()
            }
        }
    }
    
    // Helper function to initialize Mappls Map SDK
    private func initializeMapplsMap() {
        MapplsMapAuthenticator.sharedManager().initializeSDKSession { isSuccess, error in
            if let error = error {
                print("DEBUG: Map initialization error - \(error.localizedDescription)")
            } else {
                print("DEBUG: Map is authorized successfully")
            }
        }
    }
}

// Quest Card Component
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
