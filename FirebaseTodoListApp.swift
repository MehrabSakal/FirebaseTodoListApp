//
//  FirebaseTodoListApp.swift
//  FirebaseTodoListApp
//
//  Application Entry Point initializing Firebase and injecting services.
//

import SwiftUI
import FirebaseCore

@main
struct FirebaseTodoListApp: App {
    @StateObject private var authService: AuthService
    @StateObject private var firestoreService: FirestoreService
    
    init() {
        // Initialize Firebase SDK
        FirebaseApp.configure()
        
        let auth = AuthService()
        let firestore = FirestoreService()
        _authService = StateObject(wrappedValue: auth)
        _firestoreService = StateObject(wrappedValue: firestore)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(authService: authService, firestoreService: firestoreService)
        }
    }
}
