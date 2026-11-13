//
//  TodoRowView.swift
//  FirebaseTodoListApp
//
//  Row view displaying a single Todo item in the list.
//

import SwiftUI

struct TodoRowView: View {
    let todo: TodoItem
    let onToggle: () -> Void
    let onEdit: () -> Void
    
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
    
    private var formattedDate: String {
        Self.dateFormatter.string(from: todo.createdAt)
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            // Completion Checkbox
            Button(action: onToggle) {
                Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "circle")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundColor(todo.isCompleted ? .green : .gray.opacity(0.6))
            }
            .buttonStyle(BorderlessButtonStyle())
            .padding(.top, 2)
            
            // Task Content
            VStack(alignment: .leading, spacing: 4) {
                Text(todo.title)
                    .font(.headline)
                    .foregroundColor(todo.isCompleted ? .secondary : .primary)
                    .strikethrough(todo.isCompleted, color: .secondary)
                
                if !todo.description.isEmpty {
                    Text(todo.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Text(formattedDate)
                    .font(.caption2)
                    .foregroundColor(.gray)
                    .padding(.top, 2)
            }
            
            Spacer()
            
            // Edit Button
            Button(action: onEdit) {
                Image(systemName: "pencil")
                    .font(.system(size: 15))
                    .foregroundColor(.blue)
                    .padding(6)
                    .background(Color.blue.opacity(0.1))
                    .clipShape(Circle())
            }
            .buttonStyle(BorderlessButtonStyle())
        }
        .padding(.vertical, 6)
        .contentShape(Rectangle())
    }
}

#Preview {
    TodoRowView(
        todo: TodoItem(
            id: "1",
            title: "Submit Lab Assignment",
            description: "Push repository to GitHub and submit the link before deadline.",
            isCompleted: false,
            createdAt: Date()
        ),
        onToggle: {},
        onEdit: {}
    )
    .padding()
}
