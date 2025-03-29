//
//  Web3AuthHelper.swift
//  ios-solana-example
//
//  Created by Ayush B on 26/02/24.
//

import Foundation
import Web3Auth

class Web3AuthHelper {
    
    private(set) var web3Auth: Web3Auth?
    private var isInitialized = false
    
    func initialize() async throws {
        do {
            print("Initializing Web3Auth with client ID: BNOIH52LcDndVctBMe1ChZuBoITJNnRDgIkZ2rKn8SYpQ1XuQjLi_FREsxBxhjUuasC1e-CM7ydyWye8uljpCHI")
            web3Auth = try await Web3Auth(
                W3AInitParams(
                    clientId: "BNOIH52LcDndVctBMe1ChZuBoITJNnRDgIkZ2rKn8SYpQ1XuQjLi_FREsxBxhjUuasC1e-CM7ydyWye8uljpCHI",
                    network: Network.sapphire_devnet,
                    redirectUrl: "com.w3a.ios-solana-example://auth"
                )
            )
            isInitialized = true
            print("Web3Auth initialized successfully")
        } catch let error {
            print("Web3Auth initialization failed: \(error.localizedDescription)")
            isInitialized = false
            throw error
        }
    }
    
    func isUserAuthenticated() -> Bool {
        guard let web3Auth = web3Auth else { return false }
        return web3Auth.state != nil
    }
    
    func logOut() async throws {
        guard let web3Auth = web3Auth else {
            throw NSError(domain: "Web3AuthHelper", code: -1, userInfo: [NSLocalizedDescriptionKey: "Web3Auth not initialized"])
        }
        return try await web3Auth.logout()
    }
    
    func getUserDetails() throws -> Web3AuthUserInfo {
        guard let web3Auth = web3Auth else {
            throw NSError(domain: "Web3AuthHelper", code: -1, userInfo: [NSLocalizedDescriptionKey: "Web3Auth not initialized"])
        }
        return try web3Auth.getUserInfo()
    }
    
    func getSolanaPrivateKey() throws -> String {
        guard let web3Auth = web3Auth else {
            throw NSError(domain: "Web3AuthHelper", code: -1, userInfo: [NSLocalizedDescriptionKey: "Web3Auth not initialized"])
        }
        return web3Auth.getEd25519PrivKey()
    }
    
    func login() async throws {
        guard let web3Auth = web3Auth else {
            throw NSError(domain: "Web3AuthHelper", code: -1, userInfo: [NSLocalizedDescriptionKey: "Web3Auth not initialized"])
        }
        
        do {
            print("Starting login process...")
            let _ = try await web3Auth.login(W3ALoginParams(
                loginProvider: Web3AuthProvider.GOOGLE)
            )
            print("Login completed successfully")
        } catch let error {
            print("Login failed: \(error.localizedDescription)")
            throw error
        }
    }
}
