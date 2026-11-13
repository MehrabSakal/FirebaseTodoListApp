//
//  FirestoreService.swift
//  FirebaseTodoListApp
//
//  Service managing Cloud Firestore CRUD operations for Todo items.
//

import Foundation
import FirebaseFirestore

class FirestoreService: ObservableObject {
    @Published var todos: [TodoItem] = []
    
    private let db = Firestore.firestore()
    private var listenerRegistration: ListenerRegistration?
    
    deinit {
        stopListening()
    }
    
    // Collection reference for a specific user: users/{userId}/todos
    private func userTodosRef(for userId: String) -> CollectionReference {
        return db.collection("users").document(userId).collection("todos")
    }
    
    // Start listening in real-time to the current user's todo collection
    func startListening(for userId: String) {
        stopListening() // Remove any existing listener
        
        listenerRegistration = userTodosRef(for: userId)
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    if let error = error {
                        print("Error listening to Firestore updates: \(error.localizedDescription)")
                        return
                    }
                    
                    guard let documents = snapshot?.documents else {
                        self.todos = []
                        return
                    }
                    
                    self.todos = documents.compactMap { doc -> TodoItem? in
                        try? doc.data(as: TodoItem.self)
                    }
                }
            }
    }
    
    // Stop listening when user logs out
    func stopListening() {
        listenerRegistration?.remove()
        listenerRegistration = nil
        self.todos = []
    }
    
    // CREATE: Add a new Todo
    func addTodo(userId: String, title: String, description: String) async throws {
        let newTodo = TodoItem(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            description: description.trimmingCharacters(in: .whitespacesAndNewlines),
            isCompleted: false,
            createdAt: Date()
        )
        _ = try userTodosRef(for: userId).addDocument(from: newTodo)
    }
    
    // UPDATE: Update title and description
    func updateTodo(userId: String, todo: TodoItem) async throws {
        guard let todoId = todo.id else { return }
        try userTodosRef(for: userId).document(todoId).setData(from: todo, merge: true)
    }
    
    // UPDATE: Toggle completion status
    func toggleCompletion(userId: String, todo: TodoItem) async throws {
        guard let todoId = todo.id else { return }
        let updatedStatus = !todo.isCompleted
        try await userTodosRef(for: userId).document(todoId).updateData([
            "isCompleted": updatedStatus
        ])
    }
    
    // DELETE: Remove a Todo
    func deleteTodo(userId: String, todoId: String) async throws {
        try await userTodosRef(for: userId).document(todoId).delete()
    }
}
