//
//  AuthViewModel.swift
//  FirebaseTodoListApp
//
//  ViewModel handling authentication UI logic, validation, and states.
//

import Foundation
import FirebaseAuth

@MainActor
class AuthViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showErrorAlert = false
    
    private let authService: AuthService
    
    init(authService: AuthService) {
        self.authService = authService
    }
    
    func signIn() async {
        guard validateFields(isSignUp: false) else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            try await authService.signIn(email: email.trimmingCharacters(in: .whitespacesAndNewlines), password: password)
            resetFields()
        } catch {
            errorMessage = error.localizedDescription
            showErrorAlert = true
        }
        
        isLoading = false
    }
    
    func signUp() async {
        guard validateFields(isSignUp: true) else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            try await authService.signUp(email: email.trimmingCharacters(in: .whitespacesAndNewlines), password: password)
            resetFields()
        } catch {
            errorMessage = error.localizedDescription
            showErrorAlert = true
        }
        
        isLoading = false
    }
    
    func signOut() {
        do {
            try authService.signOut()
            resetFields()
        } catch {
            errorMessage = error.localizedDescription
            showErrorAlert = true
        }
    }
    
    private func validateFields(isSignUp: Bool) -> Bool {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedEmail.isEmpty || !trimmedEmail.contains("@") {
            errorMessage = "Please enter a valid email address."
            showErrorAlert = true
            return false
        }
        
        if password.count < 6 {
            errorMessage = "Password must be at least 6 characters long."
            showErrorAlert = true
            return false
        }
        
        if isSignUp && password != confirmPassword {
            errorMessage = "Passwords do not match."
            showErrorAlert = true
            return false
        }
        
        return true
    }
    
    func clearErrors() {
        errorMessage = nil
        showErrorAlert = false
    }
    
    private func resetFields() {
        email = ""
        password = ""
        confirmPassword = ""
        errorMessage = nil
        showErrorAlert = false
    }
}
