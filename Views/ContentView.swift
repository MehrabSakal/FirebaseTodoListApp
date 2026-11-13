//
//  ContentView.swift
//  FirebaseTodoListApp
//
//  Root navigation controller switching between Authentication and Todo Dashboard.
//

import SwiftUI
import FirebaseAuth

struct ContentView: View {
    @ObservedObject var authService: AuthService
    @StateObject private var authViewModel: AuthViewModel
    @StateObject private var todoViewModel: TodoViewModel
    
    init(authService: AuthService, firestoreService: FirestoreService) {
        self.authService = authService
        _authViewModel = StateObject(wrappedValue: AuthViewModel(authService: authService))
        _todoViewModel = StateObject(wrappedValue: TodoViewModel(firestoreService: firestoreService))
    }
    
    var body: some View {
        Group {
            if let user = authService.currentUser {
                TodoListView(
                    todoViewModel: todoViewModel,
                    authViewModel: authViewModel,
                    user: user
                )
            } else {
                LoginView(authViewModel: authViewModel)
            }
        }
        .task(id: authService.currentUser?.uid) {
            todoViewModel.setUser(authService.currentUser)
        }
    }
}
