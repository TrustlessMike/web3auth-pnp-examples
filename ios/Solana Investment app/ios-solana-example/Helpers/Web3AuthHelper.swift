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
            chainNamespace: .solana,
            decimals: 9,
            blockExplorerUrl: "https://explorer.solana.com",
            chainId: "mainnet-beta",
            displayName: "Solana Mainnet",
            logo: "https://raw.githubusercontent.com/solana-labs/token-list/main/assets/mainnet/So11111111111111111111111111111111111111112/logo.png",
            rpcTarget: "https://api.mainnet-beta.solana.com",
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
        
        let state = try await web3Auth.login()
        return state.userInfo
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