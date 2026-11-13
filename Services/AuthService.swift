//
//  AuthService.swift
//  FirebaseTodoListApp
//
//  Service managing Firebase Authentication operations.
//

import Foundation
import FirebaseAuth

class AuthService: ObservableObject {
    @Published var currentUser: FirebaseAuth.User?
    private var authStateListenerHandle: AuthStateDidChangeListenerHandle?

    init() {
        self.currentUser = Auth.auth().currentUser
        listenToAuthChanges()
    }

    deinit {
        if let handle = authStateListenerHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }

    private func listenToAuthChanges() {
        authStateListenerHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.currentUser = user
            }
        }
    }

    // Sign up with Email and Password
    func signUp(email: String, password: String) async throws {
        _ = try await Auth.auth().createUser(withEmail: email, password: password)
    }

    // Sign in with Email and Password
    func signIn(email: String, password: String) async throws {
        _ = try await Auth.auth().signIn(withEmail: email, password: password)
    }

    // Sign out
    func signOut() throws {
        try Auth.auth().signOut()
        self.currentUser = nil
    }
}
