
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

class AuthViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var username = ""
    @Published var gender: AppUser.Gender = .other
    @Published var errorMessage = ""
    @Published var isLoading = false
    @Published var isLogin = true
    
    private let db = Firestore.firestore()
    
    func authenticate(completion: @escaping () -> Void) {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please fill in all required fields"
            return
        }
        
        isLoading = true
        errorMessage = ""
        
        if isLogin {
            signIn(completion: completion)
        } else {
            signUp(completion: completion)
        }
    }
    
    private func signIn(completion: @escaping () -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            guard let self = self else { return }
            self.isLoading = false
            
            if let error = error {
                self.errorMessage = error.localizedDescription
                print("DEBUG: Login failed - \(error.localizedDescription)")
            } else {
                print("DEBUG: Login successful")
                completion()
            }
        }
    }
    
    private func signUp(completion: @escaping () -> Void) {
        guard !username.isEmpty else {
            errorMessage = "Please enter a username"
            isLoading = false
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            guard let self = self else { return }
            
            if let error = error {
                self.isLoading = false
                self.errorMessage = error.localizedDescription
                print("DEBUG: Signup failed - \(error.localizedDescription)")
                return
            }
            
            guard let user = result?.user else {
                self.isLoading = false
                self.errorMessage = "Failed to create user"
                return
            }
            
            print("DEBUG: User created successfully with UID: \(user.uid)")
            
            // Create user profile in Firestore
            let userData: [String: Any] = [
                "username": self.username,
                "email": self.email,
                "gender": self.gender.rawValue,
                "totalPoints": 0,
                "questsCompleted": 0,
                "questsCreated": 0,
                "createdAt": Timestamp(date: Date())
            ]
            
            self.db.collection("users").document(user.uid).setData(userData) { [weak self] error in
                self?.isLoading = false
                
                if let error = error {
                    print("DEBUG: Error creating user profile - \(error.localizedDescription)")
                    self?.errorMessage = "Failed to create user profile"
                } else {
                    print("DEBUG: User profile created successfully")
                    completion()
                }
            }
        }
    }
    
    func resetFields() {
        email = ""
        password = ""
        username = ""
        errorMessage = ""
    }
}
