import SwiftUI
import Web3Auth

class ViewModel: ObservableObject {
    @Published var isLoggedIn = false
    @Published var userInfo: Web3AuthUserInfo?
    private let web3AuthHelper = Web3AuthHelper()
    
    init() {
        print("Initializing ViewModel...")
        Task {
            do {
                try await web3AuthHelper.initialize()
                print("Web3AuthHelper initialized in ViewModel")
            } catch {
                print("Error initializing Web3AuthHelper in ViewModel: \(error)")
            }
        }
    }
    
    func login() {
        print("ViewModel: Starting login process...")
        Task {
            do {
                try await web3AuthHelper.login()
                userInfo = try web3AuthHelper.getUserDetails()
                isLoggedIn = true
                print("ViewModel: Login successful")
            } catch {
                print("ViewModel: Login failed - \(error)")
            }
        }
    }
    
    func logout() {
        print("ViewModel: Starting logout process...")
        Task {
            do {
                try await web3AuthHelper.logOut()
                userInfo = nil
                isLoggedIn = false
                print("ViewModel: Logout successful")
            } catch {
                print("ViewModel: Logout failed - \(error)")
            }
        }
    }
} 