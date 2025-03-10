import Foundation
import FirebaseFirestore

struct AppUser: Identifiable {
    var id: String { uid }
    let uid: String
    var username: String?
    var email: String?
    var gender: Gender
    var totalPoints: Int
    var questsCompleted: Int
    var questsCreated: Int
    var createdAt: Date
    
    enum Gender: String, Codable {
        case male
        case female
        case other
        
        var emoji: String {
            switch self {
            case .male: return "👨"
            case .female: return "👩"
            case .other: return "👤"
            }
        }
    }
    
    init(uid: String, email: String? = nil) {
        self.uid = uid
        self.email = email
        self.gender = .other
        self.totalPoints = 0
        self.questsCompleted = 0
        self.questsCreated = 0
        self.createdAt = Date()
    }
    
    init?(document: DocumentSnapshot) {
        guard let data = document.data() else { return nil }
        
        self.uid = document.documentID
        self.username = data["username"] as? String
        self.email = data["email"] as? String
        
        if let genderString = data["gender"] as? String,
           let gender = Gender(rawValue: genderString) {
            self.gender = gender
        } else {
            self.gender = .other
        }
        
        self.totalPoints = data["totalPoints"] as? Int ?? 0
        self.questsCompleted = data["questsCompleted"] as? Int ?? 0
        self.questsCreated = data["questsCreated"] as? Int ?? 0
        
        if let timestamp = data["createdAt"] as? Timestamp {
            self.createdAt = timestamp.dateValue()
        } else {
            self.createdAt = Date()
        }
    }
    
    func toDictionary() -> [String: Any] {
        return [
            "username": username ?? "",
            "email": email ?? "",
            "gender": gender.rawValue,
            "totalPoints": totalPoints,
            "questsCompleted": questsCompleted,
            "questsCreated": questsCreated,
            "createdAt": Timestamp(date: createdAt)
        ]
    }
}
