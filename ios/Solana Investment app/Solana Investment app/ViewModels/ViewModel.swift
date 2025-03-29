//
//  ViewModel.swift
//  ios-solana-example
//
//  Created by Ayush B on 26/02/24.
//

import Foundation
import Web3Auth

class ViewModel: ObservableObject {
    var web3AuthHelper: Web3AuthHelper!
    private var isInitializing = false
    
    @Published var isUserAuthenticated: Bool = false
    @Published var isErrorAvailable: Bool = false
    @Published var isLoading: Bool = false
    var error: String = ""
    
    
    func initialize() {
        guard !isInitializing else { return }
        isInitializing = true
        
        Task {
            do {
                print("Initializing Web3Auth...")
                web3AuthHelper = Web3AuthHelper()
                try await web3AuthHelper.initialize()
                DispatchQueue.main.async {
                    self.isUserAuthenticated = self.web3AuthHelper.isUserAuthenticated()
                    print("Initialization complete. User authenticated: \(self.isUserAuthenticated)")
                    self.isInitializing = false
                }
            } catch let error {
                DispatchQueue.main.async {
                    self.isErrorAvailable = true
                    self.error = "Initialization failed: \(error.localizedDescription)"
                    print("Initialization error: \(error.localizedDescription)")
                    self.isInitializing = false
                }
            }
        }
    }
    
    func getSolanaPrivateKey() throws -> String {
        return try web3AuthHelper.getSolanaPrivateKey()
    }
    
    func logOut() {
        Task {
            do {
                try await web3AuthHelper.logOut()
                DispatchQueue.main.async {
                    self.isUserAuthenticated = false
                }
            } catch let error {
                DispatchQueue.main.async {
                    self.isErrorAvailable = true
                    self.error = error.localizedDescription
                }
                print(error)
            }
        }
    }
    
    func login() {
        guard !isLoading else { return }
        isLoading = true
        
        Task {
            do {
                print("Starting login process...")
                try await web3AuthHelper.login()
                DispatchQueue.main.async {
                    self.isUserAuthenticated = true
                    print("Login successful")
                    self.isLoading = false
                }
            } catch let error {
                DispatchQueue.main.async {
                    self.isErrorAvailable = true
                    self.error = "Login failed: \(error.localizedDescription)"
                    print("Login error: \(error.localizedDescription)")
                    self.isLoading = false
                }
            }
        }
    }
    
    func getUserInfo() throws -> Web3AuthUserInfo {
        try web3AuthHelper.getUserDetails()
    }
}
