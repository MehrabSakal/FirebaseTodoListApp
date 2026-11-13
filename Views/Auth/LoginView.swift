//
//  LoginView.swift
//  FirebaseTodoListApp
//
//  User interface for Email/Password Login.
//

import SwiftUI

struct LoginView: View {
    @ObservedObject var authViewModel: AuthViewModel
    @State private var navigateToRegister = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 72, height: 72)
                                .foregroundColor(.blue)
                                .padding(.top, 40)
                            
                            Text("Welcome Back")
                                .font(.system(size: 28, weight: .bold))
                            
                            Text("Sign in to continue managing your tasks")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        // Form Card
                        VStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Email Address")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.secondary)
                                
                                HStack {
                                    Image(systemName: "envelope.fill")
                                        .foregroundColor(.secondary)
                                    TextField("Enter your email", text: $authViewModel.email)
                                        .keyboardType(.emailAddress)
                                        .textInputAutocapitalization(.never)
                                        .autocorrectionDisabled()
                                }
                                .padding(12)
                                .background(Color(.secondarySystemGroupedBackground))
                                .cornerRadius(10)
                            }
                            
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Password")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.secondary)
                                
                                HStack {
                                    Image(systemName: "lock.fill")
                                        .foregroundColor(.secondary)
                                    SecureField("Enter your password", text: $authViewModel.password)
                                }
                                .padding(12)
                                .background(Color(.secondarySystemGroupedBackground))
                                .cornerRadius(10)
                            }
                            
                            // Sign In Button
                            Button(action: {
                                Task {
                                    await authViewModel.signIn()
                                }
                            }) {
                                HStack {
                                    if authViewModel.isLoading {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    } else {
                                        Text("Sign In")
                                            .fontWeight(.semibold)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            }
                            .disabled(authViewModel.isLoading)
                            .padding(.top, 8)
                        }
                        .padding(20)
                        .background(Color(.systemBackground))
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                        .padding(.horizontal)
                        
                        // Register Link
                        HStack {
                            Text("Don't have an account?")
                                .foregroundColor(.secondary)
                            Button("Sign Up") {
                                authViewModel.clearErrors()
                                navigateToRegister = true
                            }
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                        }
                        .font(.subheadline)
                        .padding(.top, 8)
                    }
                }
            }
            .navigationTitle("Login")
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(isPresented: $navigateToRegister) {
                RegisterView(authViewModel: authViewModel)
            }
            .alert(
                "Authentication Error",
                isPresented: Binding(
                    get: { authViewModel.showErrorAlert && !navigateToRegister },
                    set: { authViewModel.showErrorAlert = $0 }
                )
            ) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(authViewModel.errorMessage ?? "An error occurred.")
            }
        }
    }
}

#Preview {
    LoginView(authViewModel: AuthViewModel(authService: AuthService()))
}
