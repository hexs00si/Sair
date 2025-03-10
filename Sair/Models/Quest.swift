import Foundation
import CoreLocation
import MapplsMap

struct Quest: Identifiable, Codable {
    var id: String = UUID().uuidString
    var creatorID: String
    var title: String
    var description: String
    var difficulty: Int // 1-5
    var category: String
    var pointsValue: Int
    var isPublic: Bool = true
    var completionCount: Int = 0
    var averageRating: Float = 0.0
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
    
    // Location data
    var startLocation: QuestLocation
    var endLocation: QuestLocation
    var intermediateLocations: [QuestLocation]
    
    var totalDistanceMeters: Double = 0
    var estimatedTimeMinutes: Int = 0
    
    // Route polyline - store as encoded string to save space
    var routePolyline: String?
}

struct QuestLocation: Codable, Identifiable {
    var id: String = UUID().uuidString
    var name: String
    var description: String = ""
    var latitude: Double
    var longitude: Double
    var mapplsPin: String?
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
