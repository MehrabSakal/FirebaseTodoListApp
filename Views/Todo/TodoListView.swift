//
//  TodoListView.swift
//  FirebaseTodoListApp
//
//  Main Todo List screen showing real-time tasks, filters, search, and CRUD actions.
//

import SwiftUI
import FirebaseAuth

struct TodoListView: View {
    @ObservedObject var todoViewModel: TodoViewModel
    @ObservedObject var authViewModel: AuthViewModel
    let user: FirebaseAuth.User
    
    @State private var showingAddSheet = false
    @State private var selectedTodoToEdit: TodoItem? = nil
    @State private var showingSignOutConfirmation = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Filter Segmented Control
                Picker("Filter", selection: $todoViewModel.selectedFilter) {
                    ForEach(TodoFilter.allCases) { filter in
                        Text(filter.rawValue).tag(filter)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.vertical, 8)
                
                // Tasks List or Empty State
                if todoViewModel.filteredTodos.isEmpty {
                    emptyStateView
                } else {
                    List {
                        ForEach(todoViewModel.filteredTodos) { todo in
                            TodoRowView(
                                todo: todo,
                                onToggle: {
                                    todoViewModel.toggleCompletion(todo)
                                },
                                onEdit: {
                                    selectedTodoToEdit = todo
                                }
                            )
                        }
                        .onDelete { indexSet in
                            todoViewModel.deleteTodo(at: indexSet)
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("My Tasks")
            .searchable(text: $todoViewModel.searchText, prompt: "Search title or description...")
            .toolbar {
                // Leading: User Info & Sign Out
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        Section(header: Text("Signed in as")) {
                            Text(user.email ?? "User")
                                .fontWeight(.medium)
                        }
                        
                        Button(role: .destructive) {
                            showingSignOutConfirmation = true
                        } label: {
                            Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "person.crop.circle")
                                .font(.title3)
                            Text(user.email?.components(separatedBy: "@").first ?? "Account")
                                .font(.subheadline)
                                .foregroundColor(.primary)
                        }
                    }
                }
                
                // Trailing: Add Task Button
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                    }
                }
            }
            // Sheet for Adding New Task
            .sheet(isPresented: $showingAddSheet) {
                AddEditTodoView(todoViewModel: todoViewModel)
            }
            // Sheet for Editing Existing Task
            .sheet(item: $selectedTodoToEdit) { todo in
                AddEditTodoView(todoViewModel: todoViewModel, todoToEdit: todo)
            }
            // Sign Out Confirmation Dialog
            .confirmationDialog("Are you sure you want to sign out?", isPresented: $showingSignOutConfirmation, titleVisibility: .visible) {
                Button("Sign Out", role: .destructive) {
                    authViewModel.signOut()
                }
                Button("Cancel", role: .cancel) { }
            }
            // Error Alert
            .alert("Error", isPresented: $todoViewModel.showErrorAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(todoViewModel.errorMessage ?? "An unknown error occurred.")
            }
        }
    }
    
    // View shown when there are no tasks for the active filter/search
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "checklist")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundColor(.gray.opacity(0.4))
            
            Text(todoViewModel.searchText.isEmpty ? "No Tasks Here!" : "No Matching Tasks")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text(todoViewModel.searchText.isEmpty
                 ? "Tap the + button at the top right to create your first task."
                 : "Try searching with a different keyword.")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            if todoViewModel.searchText.isEmpty {
                Button {
                    showingAddSheet = true
                } label: {
                    Label("Create Task", systemImage: "plus")
                        .fontWeight(.semibold)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.top, 8)
            }
            
            Spacer()
        }
    }
}
