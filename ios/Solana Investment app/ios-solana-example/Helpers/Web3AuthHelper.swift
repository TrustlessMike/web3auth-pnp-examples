import Foundation
import Web3Auth

class Web3AuthHelper {
    static let shared = Web3AuthHelper()
    private var web3Auth: Web3Auth?
    
    private init() {
        setupWeb3Auth()
    }
    
    private func setupWeb3Auth() {
        let clientId = "YOUR_CLIENT_ID" // Replace with your Web3Auth client ID
        let chainConfig = ChainConfig(
            chainNamespace: "solana",
            chainId: "mainnet-beta",
            rpcTarget: "https://api.mainnet-beta.solana.com",
            displayName: "Solana Mainnet",
            blockExplorer: "https://explorer.solana.com",
            ticker: "SOL",
            tickerName: "Solana"
        )
        
        let web3AuthConfig = Web3AuthConfig(
            clientId: clientId,
            chainConfig: chainConfig
        )
        
        web3Auth = Web3Auth(config: web3AuthConfig)
    }
    
    func login() async throws -> Web3AuthUserInfo {
        guard let web3Auth = web3Auth else {
            throw Web3AuthError.notInitialized
        }
        
        return try await web3Auth.login()
    }
    
    func logout() async throws {
        guard let web3Auth = web3Auth else {
            throw Web3AuthError.notInitialized
        }
        
        try await web3Auth.logout()
    }
}

enum Web3AuthError: Error {
    case notInitialized
} 