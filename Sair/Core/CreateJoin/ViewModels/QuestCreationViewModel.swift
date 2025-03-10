import SwiftUI
import MapplsAPIKit
import MapplsMap
import CoreLocation
import FirebaseFirestore
import FirebaseAuth

class QuestCreationViewModel: ObservableObject {
    // Quest details
    @Published var title: String = ""
    @Published var description: String = ""
    @Published var difficulty: Int = 2
    @Published var category: String = "Adventure"
    @Published var pointsValue: Int = 100
    @Published var isPublic: Bool = true
    
    // Location search
    @Published var startSearchText: String = ""
    @Published var endSearchText: String = ""
    @Published var searchResults: [MapplsAtlasSuggestion] = []
    @Published var isSearching: Bool = false
    @Published var searchFocus: LocationFocus = .start
    
    // Locations
    @Published var startLocation: QuestLocation?
    @Published var endLocation: QuestLocation?
    @Published var intermediateLocations: [QuestLocation] = []
    
    // Route details
    @Published var routePolyline: String?
    @Published var routeDistance: Double = 0
    @Published var routeTime: Int = 0
    @Published var isRouteCalculated: Bool = false
    @Published var isCalculatingRoute: Bool = false
    
    // Creation status
    @Published var isSaving: Bool = false
    @Published var errorMessage: String?
    @Published var createdQuest: Quest?
    @Published var currentStep: Int = 0
    
    // Categories
    let categories = ["Adventure", "Cultural", "Historical", "Nature", "Food", "Educational"]
    
    enum LocationFocus {
        case start
        case end
        case intermediate
    }
    
    // Check if user can proceed to next step
    func canProceedFromStep(_ step: Int) -> Bool {
        switch step {
        case 0: // Basic info
            return !title.isEmpty && !description.isEmpty
        case 1: // Start location
            return startLocation != nil
        case 2: // End location
            return endLocation != nil
        case 3: // Route preview
            return isRouteCalculated
        case 4: // Final details
            return true
        default:
            return false
        }
    }
    
    // MARK: - Location Search
    func searchLocations(query: String) {
        guard !query.isEmpty else {
            self.searchResults = []
            return
        }
        
        isSearching = true
        
        let options = MapplsAutoSearchAtlasOptions(query: query, withRegion: .india)
        options.location = CLLocation(latitude: 28.550834, longitude: 77.268918) // Default to Delhi if no user location
        options.zoom = 12 // Set zoom level for better results
        
        // Use getAutoSuggestionResults
        MapplsAutoSuggestManager.shared.getAutoSuggestionResults(options) { [weak self] (locationResults, error) in
            DispatchQueue.main.async {
                self?.isSearching = false
                
                if let error = error {
                    print("Search error: \(error.localizedDescription)")
                    return
                }
                
                if let results = locationResults as? MapplsAutoSuggestLocationResults {
                    self?.searchResults = results.suggestions as? [MapplsAtlasSuggestion] ?? []
                }
            }
        }
    }
    
    func selectLocation(_ suggestion: MapplsAtlasSuggestion) {
        // Create a QuestLocation object from the suggestion
        let location = QuestLocation(
            name: suggestion.placeName ?? suggestion.placeAddress ?? "",
            latitude: suggestion.latitude?.doubleValue ?? 0,
            longitude: suggestion.longitude?.doubleValue ?? 0,
            mapplsPin: suggestion.mapplsPin
        )
        
        // Assign to the appropriate location based on current focus
        switch searchFocus {
        case .start:
            startLocation = location
            startSearchText = location.name
        case .end:
            endLocation = location
            endSearchText = location.name
        case .intermediate:
            intermediateLocations.append(location)
        }
        
        // Clear search results
        searchResults = []
        
        // If both start and end locations are set, calculate route
        if startLocation != nil && endLocation != nil {
            calculateRoute()
        }
    }
    
    // MARK: - Route Calculation
    func calculateRoute() {
        guard let start = startLocation, let end = endLocation else {
            return
        }
        
        isCalculatingRoute = true
        
        var waypoints = [
            Waypoint(coordinate: start.coordinate, name: start.name),
            Waypoint(coordinate: end.coordinate, name: end.name)
        ]
        
        // Add intermediate waypoints if any
        if !intermediateLocations.isEmpty {
            for location in intermediateLocations {
                waypoints.insert(Waypoint(coordinate: location.coordinate, name: location.name), at: waypoints.count - 1)
            }
        }
        
        let options = RouteOptions(waypoints: waypoints, resourceIdentifier: .routeAdv, profileIdentifier: .driving)
        options.includesSteps = true
        
        // Fix: Create an instance of Directions and use that to calculate
        let directions = Directions.shared
        directions.calculate(options) { [weak self] (waypoints, routes, error) in
            DispatchQueue.main.async {
                self?.isCalculatingRoute = false
                
                if let error = error {
                    print("Error calculating route: \(error.localizedDescription)")
                    self?.errorMessage = "Failed to calculate route: \(error.localizedDescription)"
                    return
                }
                
                if let route = routes?.first {
                    // Fix: Route doesn't have a polyline property directly
                    // We'll store the coordinates as encoded polyline later
                    self?.routePolyline = "" // Placeholder for now
                    self?.routeDistance = route.distance
                    self?.routeTime = Int(route.expectedTravelTime / 60) // Convert to minutes
                    self?.isRouteCalculated = true
                }
            }
        }
    }
    
    // MARK: - Save Quest
    func saveQuest(completion: @escaping (Bool, String?) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {
            completion(false, "User not logged in")
            return
        }
        
        guard let start = startLocation, let end = endLocation else {
            completion(false, "Start and end locations required")
            return
        }
        
        isSaving = true
        
        // Create the quest
        let quest = Quest(
            creatorID: userID,
            title: title,
            description: description,
            difficulty: difficulty,
            category: category,
            pointsValue: pointsValue,
            startLocation: start,
            endLocation: end,
            intermediateLocations: intermediateLocations,
            totalDistanceMeters: routeDistance,
            estimatedTimeMinutes: routeTime,
            routePolyline: routePolyline
        )
        
        // Save to Firestore
        let db = Firestore.firestore()
        do {
            try db.collection("quests").document(quest.id).setData(from: quest) { [weak self] error in
                DispatchQueue.main.async {
                    self?.isSaving = false
                    
                    if let error = error {
                        completion(false, "Failed to save quest: \(error.localizedDescription)")
                    } else {
                        self?.createdQuest = quest
                        
                        // Update user's quest count
                        db.collection("users").document(userID).updateData([
                            "questsCreated": FieldValue.increment(Int64(1))
                        ])
                        
                        completion(true, nil)
                    }
                }
            }
        } catch {
            isSaving = false
            completion(false, "Failed to encode quest data: \(error.localizedDescription)")
        }
    }
    
    // Reset all fields for a new quest
    func resetQuest() {
        title = ""
        description = ""
        difficulty = 2
        category = "Adventure"
        pointsValue = 100
        isPublic = true
        startSearchText = ""
        endSearchText = ""
        startLocation = nil
        endLocation = nil
        intermediateLocations = []
        routePolyline = nil
        routeDistance = 0
        routeTime = 0
        isRouteCalculated = false
        currentStep = 0
        errorMessage = nil
        createdQuest = nil
    }
}
