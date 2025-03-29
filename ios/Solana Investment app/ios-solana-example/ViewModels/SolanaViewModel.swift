import Foundation
import SolanaSwift
import Web3Auth

class SolanaViewModel: ObservableObject {
    @Published var balance: Double = 0.0
    @Published var isLoading: Bool = false
    @Published var error: String?
    private var apiClient: JSONRPCAPIClient?
    private var account: KeyPair?
    
    // Add struct definitions at class level
    private struct BlockhashParams: Encodable {
        let commitment: String
    }
    
    private struct BlockhashResponse: Decodable {
        let value: BlockhashValue
    }
    
    private struct BlockhashValue: Decodable {
        let blockhash: String
        let lastValidBlockHeight: UInt64?
    }
    
    private struct SimulationOptions: Encodable {
        let sigVerify: Bool
        let replaceRecentBlockhash: Bool
        let preflightCommitment: String
    }
    
    private struct SimulationParams: Encodable {
        let account: String
        let transaction: String
        let options: SimulationOptions
    }
    
    private struct SimulationRequest: Encodable {
        let jsonrpc: String = "2.0"
        let id: Int = 1
        let method: String = "simulateTransaction"
        let params: [SimulationParams]
    }
    
    private struct SimulationResponse: Decodable {
        let jsonrpc: String
        let id: Int
        let result: SimulationResult?
        let error: SimulationError?
    }
    
    private struct SimulationResult: Decodable {
        let err: String?
        let logs: [String]?
        let unitsConsumed: UInt64?
    }
    
    private struct SimulationError: Decodable {
        let code: Int
        let message: String
        let data: String?
    }
    
    init() {
        print("Initializing Solana client...")
        // Initialize Solana client with Helius devnet endpoint
        let endpoint = APIEndPoint(
            address: "https://devnet.helius-rpc.com/?api-key=3da557dc-d7a7-4670-a986-6741a358a726",
            network: .devnet
        )
        apiClient = JSONRPCAPIClient(endpoint: endpoint)
        print("Solana client initialized with endpoint: \(endpoint.address)")
    }
    
    func setupAccount(privateKey: String) throws {
        print("Setting up Solana account with private key...")
        // Convert hex string to Data
        let privateKeyData: Data
        if privateKey.hasPrefix("0x") {
            let hexString = String(privateKey.dropFirst(2))
            privateKeyData = Data(hexString: hexString) ?? Data()
        } else {
            privateKeyData = Data(hexString: privateKey) ?? Data()
        }
        
        guard !privateKeyData.isEmpty else {
            print("Failed to convert private key to data")
            throw SolanaError.invalidPrivateKey
        }
        
        self.account = try KeyPair(secretKey: privateKeyData)
        print("Account setup successful")
        print("Public key: \(self.account?.publicKey.base58EncodedString ?? "none")")
    }
    
    func fetchBalance() async {
        guard let apiClient = apiClient, let account = account else {
            error = "Solana client or account not initialized"
            return
        }
        
        do {
            print("Fetching balance for account: \(account.publicKey.base58EncodedString)")
            let balance = try await apiClient.getBalance(account: account.publicKey.base58EncodedString)
            print("Balance received: \(balance) lamports")
            DispatchQueue.main.async {
                self.balance = Double(balance) / 1_000_000_000.0 // Convert lamports to SOL
                self.error = nil
            }
        } catch {
            print("Balance fetch error: \(error)")
            if let responseError = error as? ResponseError {
                print("Response error code: \(String(describing: responseError.code))")
                print("Response error message: \(String(describing: responseError.message))")
                print("Response error data: \(String(describing: responseError.data))")
            }
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
            print("Requesting airdrop of 1 SOL to account: \(account.publicKey.base58EncodedString)")
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
            print("Airdrop error: \(error)")
            if let responseError = error as? ResponseError {
                print("Response error code: \(String(describing: responseError.code))")
                print("Response error message: \(String(describing: responseError.message))")
                print("Response error data: \(String(describing: responseError.data))")
            }
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
            print("Creating transfer instruction...")
            let transferInstruction = SystemProgram.transferInstruction(
                from: account.publicKey,
                to: destination,
                lamports: amount
            )
            print("Transfer instruction created")
            
            // Get initial blockhash with finalized commitment
            print("Getting initial blockhash...")
            let params = BlockhashParams(commitment: "finalized")
            let response: BlockhashResponse = try await apiClient.request(method: "getLatestBlockhash", params: [params])
            let initialBlockhash = response.value.blockhash
            print("Got initial blockhash: \(initialBlockhash)")
            
            print("Creating transaction...")
            var transaction = Transaction()
            transaction.instructions = [transferInstruction]
            transaction.recentBlockhash = initialBlockhash
            transaction.feePayer = account.publicKey
            print("Transaction created, signing...")
            
            try transaction.sign(signers: [account])
            print("Transaction signed")
            
            print("Serializing transaction...")
            var serializedTransaction = try transaction.serialize().base64EncodedString()
            print("Transaction serialized")
            
            // Add retry logic for sending transaction
            var retryCount = 0
            let maxRetries = 3
            var lastError: Error?
            
            while retryCount < maxRetries {
                do {
                    // Get fresh blockhash immediately before sending
                    print("Getting fresh blockhash for attempt \(retryCount + 1)...")
                    let newResponse: BlockhashResponse = try await apiClient.request(method: "getLatestBlockhash", params: [params])
                    
                    // Preflight check
                    print("Performing preflight check...")
                    let config = RequestConfiguration(
                        commitment: "finalized",
                        encoding: "base64",
                        skipPreflight: false
                    )!
                    let simulationResult = try await apiClient.simulateTransaction(
                        transaction: serializedTransaction,
                        configs: config
                    )
                    
                    if simulationResult.err != nil {
                        print("Preflight check failed: \(String(describing: simulationResult.err))")
                        throw SolanaError.invalidResponse
                    }
                    
                    transaction.recentBlockhash = newResponse.value.blockhash
                    try transaction.sign(signers: [account])
                    serializedTransaction = try transaction.serialize().base64EncodedString()
                    
                    print("Sending transaction to network (attempt \(retryCount + 1)/\(maxRetries))...")
                    let signature = try await apiClient.sendTransaction(transaction: serializedTransaction)
                    print("Transaction sent successfully. Signature: \(signature)")
                    
                    // Wait for confirmation with finalized commitment
                    print("Waiting for transaction confirmation...")
                    try await apiClient.waitForConfirmation(signature: signature, ignoreStatus: false)
                    print("Transaction confirmed!")
                    
                    // Refresh balance
                    print("Refreshing balance...")
                    await fetchBalance()
                    print("Balance updated")
                    
                    DispatchQueue.main.async {
                        self.isLoading = false
                        self.error = nil
                    }
                    return
                } catch {
                    lastError = error
                    print("Transaction attempt \(retryCount + 1) failed: \(error)")
                    if let responseError = error as? ResponseError {
                        print("Response error code: \(String(describing: responseError.code))")
                        print("Response error message: \(String(describing: responseError.message))")
                    }
                    
                    retryCount += 1
                    if retryCount < maxRetries {
                        print("Waiting before retry...")
                        try await Task.sleep(nanoseconds: 500_000_000) // Wait 0.5 seconds before retry
                    }
                }
            }
            
            // If we get here, all retries failed
            throw lastError ?? SolanaError.invalidResponse
        } catch {
            print("Transaction error: \(error)")
            if let responseError = error as? ResponseError {
                print("Response error code: \(String(describing: responseError.code))")
                print("Response error message: \(String(describing: responseError.message))")
                print("Response error data: \(String(describing: responseError.data))")
            }
            DispatchQueue.main.async {
                self.isLoading = false
                self.error = "Failed to send test transaction: \(error.localizedDescription)"
            }
        }
    }
}

enum SolanaError: Error {
    case invalidPrivateKey
    case invalidResponse
}

// Helper extension to convert hex string to Data
extension Data {
    init?(hexString: String) {
        let len = hexString.count / 2
        var data = Data(capacity: len)
        var i = hexString.startIndex
        for _ in 0..<len {
            let j = hexString.index(i, offsetBy: 2)
            let bytes = hexString[i..<j]
            if var num = UInt8(bytes, radix: 16) {
                data.append(&num, count: 1)
            } else {
                return nil
            }
            i = j
        }
        self = data
    }
} 
