//
//  AddEditTodoView.swift
//  FirebaseTodoListApp
//
//  Modal Sheet for Creating a new Todo or Editing an existing Todo.
//

import SwiftUI

struct AddEditTodoView: View {
    @ObservedObject var todoViewModel: TodoViewModel
    @Environment(\.dismiss) private var dismiss
    
    var todoToEdit: TodoItem?
    
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var isCompleted: Bool = false
    
    private var isEditMode: Bool {
        todoToEdit != nil
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Task Details")) {
                    TextField("Title (e.g. Finish Lab Assignment)", text: $title)
                        .font(.body)
                }
                
                Section(header: Text("Description (Optional)")) {
                    TextEditor(text: $description)
                        .frame(minHeight: 120)
                }
                
                if isEditMode {
                    Section(header: Text("Status")) {
                        Toggle("Mark as Completed", isOn: $isCompleted)
                    }
                }
            }
            .navigationTitle(isEditMode ? "Edit Task" : "New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(isEditMode ? "Save" : "Add") {
                        saveAction()
                    }
                    .fontWeight(.semibold)
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || todoViewModel.isProcessing)
                }
            }
            .onAppear {
                if let todo = todoToEdit {
                    self.title = todo.title
                    self.description = todo.description
                    self.isCompleted = todo.isCompleted
                }
            }
            .overlay {
                if todoViewModel.isProcessing {
                    ZStack {
                        Color.black.opacity(0.15).ignoresSafeArea()
                        ProgressView()
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(10)
                            .shadow(radius: 5)
                    }
                }
            }
        }
    }
    
    private func saveAction() {
        Task {
            var success = false
            if let existingTodo = todoToEdit {
                var updated = existingTodo
                updated.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
                updated.description = description.trimmingCharacters(in: .whitespacesAndNewlines)
                updated.isCompleted = isCompleted
                success = await todoViewModel.updateTodo(updated)
            } else {
                success = await todoViewModel.addTodo(title: title, description: description)
            }
            
            if success {
                dismiss()
            }
        }
    }
}

#Preview {
    AddEditTodoView(todoViewModel: TodoViewModel(firestoreService: FirestoreService()))
}
