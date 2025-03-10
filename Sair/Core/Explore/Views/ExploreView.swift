// Sair/Core/Explore/Views/ExploreView.swift
import SwiftUI
import MapplsMap
import CoreLocation

struct ExploreView: View {
    @StateObject private var locationManager = LocationViewModel()
    @State private var mapView: MapplsMapView?
    @State private var mapLoaded = false
    @State private var showLocationPrompt = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.backgroundCream.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Map view
                    ZStack {
                        MapViewContainer(mapView: $mapView, onMapLoaded: {
                            mapLoaded = true
                        })
                        .frame(height: 300)
                        .cornerRadius(20)
                        .padding(.horizontal)
                        .padding(.top)
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                        
                        // Map loading indicator
                        if !mapLoaded {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .primaryGreen))
                                .scaleEffect(1.5)
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
                                    } else {
                                        showLocationPrompt = true
                                    }
                                }) {
                                    Image(systemName: "location.fill")
                                        .foregroundColor(.primaryGreen)
                                        .padding(12)
                                        .background(Color.white)
                                        .clipShape(Circle())
                                        .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
                                }
                                .padding(16)
                            }
                        }
                    }
                    
                    ScrollView {
                        VStack(spacing: 20) {
                            // Dynamic greeting section
                            VStack(alignment: .leading, spacing: 5) {
                                Text(getTimeBasedGreeting())
                                    .font(.headline)
                                    .foregroundColor(.primaryGreen)
                                
                                Text("Explore new adventures nearby!")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
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
                        }
                        .padding(.top)
                    }
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
                // Initialize Mappls Map SDK
                initializeMapplsMap()
                locationManager.requestLocation()
            }
            .alert(isPresented: $showLocationPrompt) {
                Alert(
                    title: Text("Location Access"),
                    message: Text("Please enable location services to see your position on the map"),
                    primaryButton: .default(Text("Settings"), action: {
                        // Open app settings
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    }),
                    secondaryButton: .cancel()
                )
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
    
    // Helper to get a greeting based on time of day
    private func getTimeBasedGreeting() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        
        if hour >= 0 && hour < 12 {
            return "Good morning!"
        } else if hour >= 12 && hour < 17 {
            return "Good afternoon!"
        } else {
            return "Good evening!"
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
