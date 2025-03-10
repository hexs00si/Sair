import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = AuthViewModel()
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            Color.backgroundCream.ignoresSafeArea()
            
            VStack(spacing: 25) {
                // Logo and app title
                VStack(spacing: 15) {
                    Image(systemName: "figure.hiking")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.primaryGreen)
                    
                    Text("Sair")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.primaryGreen)
                    
                    Text("Explore • Create • Connect")
                        .font(.subheadline)
                        .foregroundColor(Color.primaryGreen.opacity(0.8))
                }
                .padding(.top, 50)
                
                // Form fields with improved styling
                VStack(spacing: 20) {
                    if !viewModel.isLogin {
                        TextField("Username", text: $viewModel.username)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                            .autocapitalization(.none)
                        
                        // Gender selection
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Choose Avatar")
                                .font(.caption)
                                .foregroundColor(.primaryGreen)
                                .padding(.leading, 5)
                            
                            Picker(selection: $viewModel.gender, label: Text("Gender")) {
                                Text("Male \(AppUser.Gender.male.emoji)").tag(AppUser.Gender.male)
                                Text("Female \(AppUser.Gender.female.emoji)").tag(AppUser.Gender.female)
                                Text("Other \(AppUser.Gender.other.emoji)").tag(AppUser.Gender.other)
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .background(Color.white)
                            .cornerRadius(8)
                        }
                    }
                    
                    TextField("Email", text: $viewModel.email)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    
                    SecureField("Password", text: $viewModel.password)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    
                    if !viewModel.errorMessage.isEmpty {
                        Text(viewModel.errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                            .padding(.top, -5)
                    }
                }
                .padding(.horizontal, 30)
                
                // Sign in/up button with improved design
                Button(action: {
                    viewModel.authenticate {
                        // Success callback
                    }
                }) {
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text(viewModel.isLogin ? "Sign In" : "Create Account")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.primaryGreen)
                .foregroundColor(.white)
                .cornerRadius(12)
                .shadow(color: Color.primaryGreen.opacity(0.4), radius: 5, x: 0, y: 3)
                .padding(.horizontal, 30)
                .disabled(viewModel.isLoading)
                
                // Toggle button with improved styling
                Button(action: {
                    withAnimation {
                        viewModel.isLogin.toggle()
                        viewModel.errorMessage = ""
                    }
                }) {
                    Text(viewModel.isLogin ? "Don't have an account? Sign Up" : "Already have an account? Sign In")
                        .font(.footnote)
                        .fontWeight(.medium)
                        .foregroundColor(.primaryGreen)
                        .underline()
                }
                .padding(.top, 5)
                
                Spacer()
            }
            .padding()
        }
        .onAppear {
            viewModel.resetFields()
        }
    }
}
