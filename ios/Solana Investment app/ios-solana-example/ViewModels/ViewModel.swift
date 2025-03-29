import SwiftUI
import Web3Auth

class ViewModel: ObservableObject {
    @Published var isLoggedIn = false
    @Published var userInfo: Web3AuthUserInfo?
    private let web3AuthHelper = Web3AuthHelper()
    @Published var solanaViewModel = SolanaViewModel()
    
    init() {
        print("Initializing ViewModel...")
        Task {
            do {
                try await web3AuthHelper.initialize()
                print("Web3AuthHelper initialized in ViewModel")
                // Check if user is already logged in
                if web3AuthHelper.isUserAuthenticated() {
                    userInfo = try web3AuthHelper.getUserDetails()
                    let privateKey = try web3AuthHelper.getSolanaPrivateKey()
                    try solanaViewModel.setupAccount(privateKey: privateKey)
                    await solanaViewModel.fetchBalance()
                    isLoggedIn = true
                }
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
                let privateKey = try web3AuthHelper.getSolanaPrivateKey()
                try solanaViewModel.setupAccount(privateKey: privateKey)
                await solanaViewModel.fetchBalance()
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
                solanaViewModel = SolanaViewModel() // Reset Solana view model
                print("ViewModel: Logout successful")
            } catch {
                print("ViewModel: Logout failed - \(error)")
            }
        }
    }
} 