import Foundation
import Web3Auth

class Web3AuthHelper {
    var web3Auth: Web3Auth?
    
    func initialize() async throws {
        print("Starting Web3Auth initialization...")
        do {
            let clientId = "BNOIH52LcDndVctBMe1ChZuBoITJNnRDgIkZ2rKn8SYpQ1XuQjLi_FREsxBxhjUuasC1e-CM7ydyWye8uljpCHI"
            
            web3Auth = try await Web3Auth(
                W3AInitParams(
                    clientId: clientId,
                    network: Network.sapphire_devnet,
                    redirectUrl: "com.w3a.ios-solana-example://auth"
                )
            )
            print("Web3Auth initialized successfully")
        } catch let error {
            print("Error initializing Web3Auth: \(error.localizedDescription)")
            print("Detailed error: \(error)")
            throw error
        }
    }
    
    func isUserAuthenticated() -> Bool {
        guard let web3Auth = web3Auth else {
            print("Web3Auth not initialized")
            return false
        }
        let isAuthenticated = web3Auth.state != nil
        print("User authentication status: \(isAuthenticated)")
        return isAuthenticated
    }
    
    func logOut() async throws {
        print("Starting logout process...")
        guard let web3Auth = web3Auth else {
            print("Web3Auth not initialized")
            throw Web3AuthError.notInitialized
        }
        do {
            try await web3Auth.logout()
            print("Logout successful")
        } catch {
            print("Error during logout: \(error.localizedDescription)")
            throw error
        }
    }
    
    func getUserDetails() throws -> Web3AuthUserInfo {
        print("Fetching user details...")
        guard let web3Auth = web3Auth else {
            print("Web3Auth not initialized")
            throw Web3AuthError.notInitialized
        }
        do {
            let userInfo = try web3Auth.getUserInfo()
            print("User details fetched successfully")
            print("User email: \(userInfo.email ?? "Not available")")
            return userInfo
        } catch {
            print("Error fetching user details: \(error.localizedDescription)")
            throw error
        }
    }
    
    func getSolanaPrivateKey() throws -> String {
        print("Fetching Solana private key...")
        guard let web3Auth = web3Auth else {
            print("Web3Auth not initialized")
            throw Web3AuthError.notInitialized
        }
        let privateKey = web3Auth.getEd25519PrivKey()
        print("Solana private key fetched successfully")
        // If the private key doesn't start with 0x, add it
        return privateKey.hasPrefix("0x") ? privateKey : "0x" + privateKey
    }
    
    func login() async throws {
        print("Starting login process...")
        guard let web3Auth = web3Auth else {
            print("Web3Auth not initialized")
            throw Web3AuthError.notInitialized
        }
        do {
            let _ = try await web3Auth.login(W3ALoginParams(
                loginProvider: Web3AuthProvider.GOOGLE)
            )
            print("Login successful")
        } catch {
            print("Error during login: \(error.localizedDescription)")
            print("Detailed error: \(error)")
            throw error
        }
    }
}

enum Web3AuthError: Error {
    case notInitialized
} 