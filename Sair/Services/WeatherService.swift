//
//  WeatherService.swift
//  Sair
//
//  Created by Shravan Rajput on 10/03/25.
//

import Foundation
import MapplsAPIKit
import CoreLocation

class WeatherService: ObservableObject {
    @Published var currentWeather: MapplsWeatherResponse?
    @Published var isLoading = true
    @Published var errorMessage: String?
    
    
    func fetchWeatherForLocation(_ location: CLLocation) {
        print("DEBUG: Fetching weather for location: \(location.coordinate.latitude), \(location.coordinate.longitude)")
        isLoading = true
        errorMessage = nil
        
        let options = MapplsWeatherRequestOptions(location: location)
        options.theme = .light
        options.size = .size36PX
        options.tempUnit = "C"
        
        // For forecast (optional)
        options.unitType = .day
        options.unit = "1"
        
        print("DEBUG: Calling MapplsWeatherManager.getResults")
        MapplsWeatherManager.shared.getResults(options) { [weak self] weatherResponse, error in
            print("DEBUG: Weather API response received")
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    print("DEBUG: Weather API error - \(error.localizedDescription)")
                    self?.errorMessage = error.localizedDescription
                } else if let weatherResponse = weatherResponse {
                    print("DEBUG: Weather fetched successfully")
                    self?.currentWeather = weatherResponse
                    
                    if let data = weatherResponse.data {
                        print("DEBUG: Weather data available")
                    } else {
                        print("DEBUG: Weather data is nil")
                    }
                } else {
                    print("DEBUG: Both weatherResponse and error are nil")
                    self?.errorMessage = "Unknown error occurred"
                }
            }
        }
    }
    
    // Helper function to get weather-based activity suggestions
    func getWeatherBasedSuggestion() -> String {
        guard let weatherData = currentWeather?.data else {
            return "Explore new adventures nearby!"
        }
        
        // Get temperature in celsius
        guard let temperature = weatherData.temperature?.value?.floatValue else {
            return "Discover hidden gems in your area!"
        }
        
        // Get weather condition
        let weatherCondition = weatherData.weatherCondition?.weatherText?.lowercased() ?? ""
        
        // Generate suggestion based on weather
        if weatherCondition.contains("rain") || weatherCondition.contains("shower") {
            return "Perfect day for indoor quests and museum explorations!"
        } else if weatherCondition.contains("snow") {
            return "Winter wonderland! Try snow-themed adventures today."
        } else if weatherCondition.contains("cloud") {
            return "Nice cool weather for outdoor explorations!"
        } else if weatherCondition.contains("sun") || weatherCondition.contains("clear") {
            if temperature > 30 {
                return "It's hot out there! Try quests near water or in shaded areas."
            } else if temperature > 20 {
                return "Perfect weather for outdoor adventures!"
            } else {
                return "Great day for active quests and hiking adventures!"
            }
        } else if weatherCondition.contains("fog") || weatherCondition.contains("mist") {
            return "Mysterious weather perfect for urban exploration!"
        } else if temperature < 10 {
            return "Brr! Bundle up for some cozy indoor quests today."
        }
        
        return "Adventure awaits! Discover quests around you."
    }
    
    // Helper to get a greeting based on time of day
    func getTimeBasedGreeting() -> String {
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
