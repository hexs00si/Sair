import Foundation
import CoreLocation

class WeatherService: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var currentHour: Int
    
    init() {
        self.currentHour = Calendar.current.component(.hour, from: Date())
        // Refresh the current hour every 15 minutes
        Timer.scheduledTimer(withTimeInterval: 900, repeats: true) { [weak self] _ in
            self?.currentHour = Calendar.current.component(.hour, from: Date())
        }
    }
    
    // This is a placeholder method to maintain compatibility
    func fetchWeatherForLocation(_ location: CLLocation) {
        // Do nothing to prevent repeated API calls
        isLoading = false
    }
    
    // Helper to get a greeting based on time of day
    func getTimeBasedGreeting() -> String {
        if currentHour >= 0 && currentHour < 12 {
            return "Good morning!"
        } else if currentHour >= 12 && currentHour < 17 {
            return "Good afternoon!"
        } else {
            return "Good evening!"
        }
    }
    
    // Helper to get time-based adventure suggestions
    func getTimeBasedSuggestion() -> String {
        if currentHour >= 5 && currentHour < 9 {
            return "Start your day with a morning adventure nearby!"
        } else if currentHour >= 9 && currentHour < 12 {
            return "Perfect time to explore cultural sites and museums!"
        } else if currentHour >= 12 && currentHour < 15 {
            return "Discover local cuisine and hidden gems this afternoon!"
        } else if currentHour >= 15 && currentHour < 18 {
            return "Great time for outdoor explorations and nature walks!"
        } else if currentHour >= 18 && currentHour < 21 {
            return "Explore vibrant evening spots and local hangouts!"
        } else {
            return "Discover night adventures and city lights nearby!"
        }
    }
}
