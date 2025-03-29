import Foundation
import SolanaSwift
import Web3Auth

class SolanaViewModel: ObservableObject {
    @Published var balance: Double = 0.0
    @Published var isLoading: Bool = false
    @Published var error: String?
    private var apiClient: JSONRPCAPIClient?
    private var account: Account?
    
    init() {
        // Initialize Solana client with devnet endpoint
        let endpoint = APIEndPoint(
            address: "https://api.devnet.solana.com",
            network: .devnet
        )
        apiClient = JSONRPCAPIClient(endpoint: endpoint)
    }
    
    func setupAccount(privateKey: String) throws {
        guard let privateKeyData = Data(base64Encoded: privateKey) else {
            throw SolanaError.invalidPrivateKey
        }
        self.account = try Account(secretKey: privateKeyData)
        print("Account public key: \(self.account?.publicKey.base58EncodedString ?? "none")")
    }
    
    func fetchBalance() async {
        guard let apiClient = apiClient, let account = account else {
            error = "Solana client or account not initialized"
            return
        }
        
        do {
            let balance = try await apiClient.getBalance(account: account.publicKey.base58EncodedString)
            DispatchQueue.main.async {
                self.balance = Double(balance) / 1_000_000_000.0 // Convert lamports to SOL
                self.error = nil
            }
        } catch {
            DispatchQueue.main.async {
                self.error = "Failed to fetch balance: \(error.localizedDescription)"
            }
        }
    }
    
    func requestAirdrop() async {
        guard let apiClient = apiClient, let account = account else {
            error = "Solana client or account not initialized"
            return
        }
        
        DispatchQueue.main.async {
            self.isLoading = true
            self.error = nil
        }
        
        do {
            print("Requesting airdrop of 1 SOL...")
            let signature = try await apiClient.requestAirdrop(account: account.publicKey.base58EncodedString, lamports: 1_000_000_000)
            print("Airdrop requested successfully. Signature: \(signature)")
            
            // Wait for transaction confirmation
            print("Waiting for transaction confirmation...")
            try await apiClient.waitForConfirmation(signature: signature, ignoreStatus: false)
            print("Airdrop confirmed!")
            
            // Refresh balance
            await fetchBalance()
            
            DispatchQueue.main.async {
                self.isLoading = false
                self.error = nil
            }
        } catch {
            DispatchQueue.main.async {
                self.isLoading = false
                self.error = "Failed to request airdrop: \(error.localizedDescription)"
            }
        }
    }
    
    func sendTestTransaction() async {
        guard let apiClient = apiClient, let account = account else {
            error = "Solana client or account not initialized"
            return
        }
        
        DispatchQueue.main.async {
            self.isLoading = true
            self.error = nil
        }
        
        do {
            // Create a test transaction sending 0.001 SOL to ourselves
            let amount: UInt64 = 1_000_000 // 0.001 SOL in lamports
            let destination = account.publicKey // Sending to ourselves for testing
            
            print("Creating test transaction...")
            let transferInstruction = SystemProgram.transferInstruction(
                from: account.publicKey,
                to: destination,
                lamports: amount
            )
            
            let recentBlockhash = try await apiClient.getRecentBlockhash()
            
            let transaction = Transaction(
                instructions: [transferInstruction],
                recentBlockhash: recentBlockhash,
                signers: [account]
            )
            
            print("Sending transaction...")
            let signature = try await apiClient.sendTransaction(transaction)
            print("Transaction sent successfully. Signature: \(signature)")
            
            // Wait for confirmation
            print("Waiting for transaction confirmation...")
            try await apiClient.waitForConfirmation(signature: signature, ignoreStatus: false)
            print("Transaction confirmed!")
            
            // Refresh balance
            await fetchBalance()
            
            DispatchQueue.main.async {
                self.isLoading = false
                self.error = nil
            }
        } catch {
            DispatchQueue.main.async {
                self.isLoading = false
                self.error = "Failed to send test transaction: \(error.localizedDescription)"
            }
        }
    }
}

enum SolanaError: Error {
    case invalidPrivateKey
} 