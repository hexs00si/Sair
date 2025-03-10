//
//  SessionStore.swift
//  Sair
//
//  Created by Shravan Rajput on 10/03/25.
//
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

class SessionStore: ObservableObject {
    @Published var isLoggedIn = false
    @Published var user: AppUser?
    @Published var isLoading = true
    
    private var handle: AuthStateDidChangeListenerHandle?
    private let db = Firestore.firestore()
    
    init() {
        listen()
    }
    
    deinit {
        if let handle = handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
    func listen() {
        print("DEBUG: Starting auth listener")
        
        handle = Auth.auth().addStateDidChangeListener { [weak self] (auth, firebaseUser) in
            guard let self = self else { return }
            
            self.isLoading = true
            
            if let firebaseUser = firebaseUser {
                print("DEBUG: User logged in - UID: \(firebaseUser.uid), Email: \(firebaseUser.email ?? "N/A")")
                
                // Fetch user data from Firestore
                self.fetchUserData(firebaseUser: firebaseUser) { success in
                    self.isLoggedIn = success
                    self.isLoading = false
                }
            } else {
                print("DEBUG: No user logged in")
                self.isLoggedIn = false
                self.user = nil
                self.isLoading = false
            }
        }
    }
    
    private func fetchUserData(firebaseUser: FirebaseAuth.User, completion: @escaping (Bool) -> Void) {
        db.collection("users").document(firebaseUser.uid).getDocument { [weak self] (document, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("DEBUG: Error fetching user data - \(error.localizedDescription)")
                
                // Create basic user object from auth data
                self.user = AppUser(uid: firebaseUser.uid, email: firebaseUser.email)
                completion(true)
                return
            }
            
            if let document = document, document.exists {
                print("DEBUG: User document found in Firestore")
                self.user = AppUser(document: document)
                completion(true)
            } else {
                print("DEBUG: User document not found, creating new user profile")
                
                // Create new user in Firestore
                let newUser = AppUser(uid: firebaseUser.uid, email: firebaseUser.email)
                self.user = newUser
                
                self.db.collection("users").document(firebaseUser.uid).setData(newUser.toDictionary()) { error in
                    if let error = error {
                        print("DEBUG: Error creating user document - \(error.localizedDescription)")
                    } else {
                        print("DEBUG: User document created successfully")
                    }
                    completion(true)
                }
            }
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            print("DEBUG: Sign out successful")
            self.user = nil
            self.isLoggedIn = false
        } catch {
            print("DEBUG: Sign out failed - \(error.localizedDescription)")
        }
    }
}
