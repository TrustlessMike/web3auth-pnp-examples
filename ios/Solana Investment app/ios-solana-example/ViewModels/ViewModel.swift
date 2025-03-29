import SwiftUI
import Web3Auth

class ViewModel: ObservableObject {
    @Published var isLoggedIn = false
    @Published var userInfo: Web3AuthUserInfo?
    @Published var error: String?
    private let web3AuthHelper = Web3AuthHelper()
    
    init() {
        print("Initializing ViewModel...")
        Task {
            do {
                try await web3AuthHelper.initialize()
                print("Web3AuthHelper initialized in ViewModel")
            } catch {
                print("Error initializing Web3AuthHelper in ViewModel: \(error)")
                DispatchQueue.main.async {
                    self.error = "Failed to initialize Web3Auth: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func login() {
        print("ViewModel: Starting login process...")
        Task {
            do {
                try await web3AuthHelper.login()
                userInfo = try web3AuthHelper.getUserDetails()
                DispatchQueue.main.async {
                    self.isLoggedIn = true
                    self.error = nil
                    print("ViewModel: Login successful")
                }
            } catch {
                print("ViewModel: Login failed - \(error)")
                DispatchQueue.main.async {
                    self.error = "Login failed: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func logout() {
        print("ViewModel: Starting logout process...")
        Task {
            do {
                try await web3AuthHelper.logOut()
                DispatchQueue.main.async {
                    self.userInfo = nil
                    self.isLoggedIn = false
                    self.error = nil
                    print("ViewModel: Logout successful")
                }
            } catch {
                print("ViewModel: Logout failed - \(error)")
                DispatchQueue.main.async {
                    self.error = "Logout failed: \(error.localizedDescription)"
                }
            }
        }
    }
} 