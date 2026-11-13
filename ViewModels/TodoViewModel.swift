//
//  TodoViewModel.swift
//  FirebaseTodoListApp
//
//  ViewModel handling Todo listing, filtering, search, and CRUD actions.
//

import Foundation
import FirebaseAuth

enum TodoFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case pending = "Pending"
    case completed = "Completed"
    
    var id: String { self.rawValue }
}

@MainActor
class TodoViewModel: ObservableObject {
    @Published var selectedFilter: TodoFilter = .all
    @Published var searchText: String = ""
    @Published var errorMessage: String?
    @Published var showErrorAlert = false
    @Published var isProcessing = false
    
    private let firestoreService: FirestoreService
    private var currentUserId: String?
    
    init(firestoreService: FirestoreService) {
        self.firestoreService = firestoreService
    }
    
    // Bind to current authenticated user
    func setUser(_ user: FirebaseAuth.User?) {
        if let user = user {
            self.currentUserId = user.uid
            firestoreService.startListening(for: user.uid)
        } else {
            self.currentUserId = nil
            firestoreService.stopListening()
        }
    }
    
    // Filtered & Searched todos
    var filteredTodos: [TodoItem] {
        let baseList = firestoreService.todos
        
        let statusFiltered: [TodoItem]
        switch selectedFilter {
        case .all:
            statusFiltered = baseList
        case .pending:
            statusFiltered = baseList.filter { !$0.isCompleted }
        case .completed:
            statusFiltered = baseList.filter { $0.isCompleted }
        }
        
        if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return statusFiltered
        } else {
            let query = searchText.lowercased()
            return statusFiltered.filter {
                $0.title.lowercased().contains(query) ||
                $0.description.lowercased().contains(query)
            }
        }
    }
    
    // CREATE
    func addTodo(title: String, description: String) async -> Bool {
        guard let userId = currentUserId else { return false }
        
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedTitle.isEmpty {
            errorMessage = "Task title cannot be empty."
            showErrorAlert = true
            return false
        }
        
        isProcessing = true
        defer { isProcessing = false }
        
        do {
            try await firestoreService.addTodo(userId: userId, title: trimmedTitle, description: description)
            return true
        } catch {
            errorMessage = error.localizedDescription
            showErrorAlert = true
            return false
        }
    }
    
    // UPDATE
    func updateTodo(_ todo: TodoItem) async -> Bool {
        guard let userId = currentUserId else { return false }
        
        let trimmedTitle = todo.title.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedTitle.isEmpty {
            errorMessage = "Task title cannot be empty."
            showErrorAlert = true
            return false
        }
        
        isProcessing = true
        defer { isProcessing = false }
        
        do {
            try await firestoreService.updateTodo(userId: userId, todo: todo)
            return true
        } catch {
            errorMessage = error.localizedDescription
            showErrorAlert = true
            return false
        }
    }
    
    // TOGGLE STATUS
    func toggleCompletion(_ todo: TodoItem) {
        guard let userId = currentUserId else { return }
        
        Task {
            do {
                try await firestoreService.toggleCompletion(userId: userId, todo: todo)
            } catch {
                errorMessage = error.localizedDescription
                showErrorAlert = true
            }
        }
    }
    
    // DELETE
    func deleteTodo(at offsets: IndexSet) {
        guard let userId = currentUserId else { return }
        
        let itemsToDelete = offsets.map { filteredTodos[$0] }
        for item in itemsToDelete {
            guard let id = item.id else { continue }
            Task {
                do {
                    try await firestoreService.deleteTodo(userId: userId, todoId: id)
                } catch {
                    errorMessage = error.localizedDescription
                    showErrorAlert = true
                }
            }
        }
    }
    
    func deleteTodoItem(_ todo: TodoItem) {
        guard let userId = currentUserId, let todoId = todo.id else { return }
        Task {
            do {
                try await firestoreService.deleteTodo(userId: userId, todoId: todoId)
            } catch {
                errorMessage = error.localizedDescription
                showErrorAlert = true
            }
        }
    }
}
