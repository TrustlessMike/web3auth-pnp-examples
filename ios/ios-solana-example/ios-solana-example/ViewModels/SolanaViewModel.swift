//
//  SolanaViewModel.swift
//  Solana Investment app
//
//  Created by Ayush B on 26/02/24.
//

import Foundation
import SolanaSwift

@MainActor
class SolanaViewModel: ObservableObject {
    private var solanaJSONRPCClient: JSONRPCAPIClient!
    private var blockchainClient: BlockchainClient!
    var keyPair: KeyPair!
    var balance: String!
    
    @Published var isAccountLoaded: Bool = false
    
    
    func initialize(privateKey: String) {
        let endpoint = APIEndPoint(
            address: "https://api.devnet.solana.com",
            network: .devnet
        )
        
        solanaJSONRPCClient = JSONRPCAPIClient(endpoint: endpoint)
        blockchainClient = BlockchainClient(apiClient: solanaJSONRPCClient)
        
        Task {
            do {
                try generateKeyPair(privateKey: privateKey)
                print("Checking initial balance...")
                let initialBalance = try await fetchUserBalance()
                if initialBalance == "0.0" {
                    print("No SOL detected, requesting airdrop...")
                    try await requestAirdrop()
                }
                self.balance = try await fetchUserBalance()
                
                self.isAccountLoaded = true
                
            } catch let error {
                print("Initialization error: \(error)")
            }
        }
    }
    
    private func reloadBalance() {
        isAccountLoaded = false
        
        Task {
            do {
                self.balance = try await fetchUserBalance()
                self.isAccountLoaded = true
            } catch let error {
                print(error)
            }
        }
    }
    
    private func prepareAndSignTransaction() async throws -> (Transaction, String) {
        // Check balance before preparing transaction
        let currentBalance = try await fetchUserBalance()
        print("Current balance before transaction: \(currentBalance) SOL")
        
        let lamports = 0.0001.toLamport(decimals: 9)
        print("Preparing transaction: \(lamports) lamports")
        
        // Get recent blockhash
        let recentBlockhash = try await solanaJSONRPCClient.getRecentBlockhash()
        print("Got recent blockhash: \(recentBlockhash)")
        
        // Create transfer instruction
        let instruction = SystemProgram.transferInstruction(
            from: keyPair.publicKey,
            to: keyPair.publicKey,  // Self transfer
            lamports: lamports
        )
        
        // Create transaction
        var transaction = Transaction()
        transaction.instructions = [instruction]
        transaction.recentBlockhash = recentBlockhash
        transaction.feePayer = keyPair.publicKey
        
        // Sign transaction
        try transaction.sign(signers: [keyPair])
        print("Transaction signed successfully")
        
        // Serialize the transaction
        let serializedTransaction = try transaction.serialize()
        let base64Transaction = serializedTransaction.base64EncodedString()
        
        return (transaction, base64Transaction)
    }
    
    // For production implementation:
    private func submitMetaTransaction(signedTransaction: String) async throws -> String {
        // This would be a server endpoint that:
        // 1. Validates the user's signature
        // 2. Creates a new transaction with server as fee payer
        // 3. Submits to blockchain and returns signature
        
        // For demo, we're just using direct submission
        return try await solanaJSONRPCClient.sendTransaction(
            transaction: signedTransaction
        )
    }
    
    func selfTransferSol(onSend: @escaping (String?, Error?) -> ()) {
        Task {
            do {
                print("Starting transfer transaction...")
                let (_, base64Transaction) = try await prepareAndSignTransaction()
                print("Transaction prepared and signed, sending...")
                
                print("Sending transaction: \(base64Transaction)")
                
                let signature = try await solanaJSONRPCClient.sendTransaction(
                    transaction: base64Transaction,
                    configs: .init(encoding: "base64")!  // Force unwrap since we know this is valid
                )
                print("Transaction sent successfully with signature: \(signature)")
                
                // Wait and check balance
                try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
                reloadBalance()
                onSend(signature, nil)
            } catch let error {
                print("Transfer failed with error: \(error)")
                onSend(nil, error)
            }
        }
    }
    
    func signSelfTransferSol(onSign: @escaping (String?, Error?) -> ()) {
        Task {
            do {
                print("Starting transaction signing...")
                let (_, base64Transaction) = try await prepareAndSignTransaction()
                print("Transaction signed successfully with signature: \(base64Transaction)")
                onSign(base64Transaction, nil)
            } catch let error {
                print("Transaction signing failed with error: \(error)")
                onSign(nil, error)
            }
        }
    }
    
    func generateKeyPair(privateKey: String) throws {
        do {
            keyPair = try KeyPair(secretKey: Data(hex: privateKey))
            print("KeyPair generated successfully with public key: \(keyPair.publicKey.base58EncodedString)")
        } catch {
            print("Failed to generate keypair: \(error)")
            throw error
        }
    }
    
    func fetchUserBalance() async throws -> String {
        do {
            let balance = try await solanaJSONRPCClient.getBalance(
                account: keyPair.publicKey.base58EncodedString
            )
            let balanceStr = balance.convertToBalance(decimals: 9).description
            print("Fetched balance: \(balanceStr) SOL")
            return balanceStr
        } catch {
            print("Failed to fetch balance: \(error)")
            throw error
        }
    }
    
    func requestAirdrop() async throws {
        do {
            print("Requesting airdrop of 1 SOL...")
            let signature = try await solanaJSONRPCClient.requestAirdrop(
                account: keyPair.publicKey.base58EncodedString,
                lamports: 1_000_000_000 // 1 SOL in lamports
            )
            print("Airdrop requested with signature: \(signature)")
            
            // Wait and check balance multiple times
            for attempt in 1...5 {
                print("Waiting for airdrop confirmation (attempt \(attempt))...")
                try await Task.sleep(nanoseconds: 2_000_000_000) // Wait 2 seconds
                
                let newBalance = try await fetchUserBalance()
                if newBalance != "0.0" {
                    print("Airdrop confirmed! New balance: \(newBalance) SOL")
                    return
                }
            }
            
            print("Warning: Airdrop might not have been confirmed after multiple attempts")
        } catch {
            print("Airdrop failed: \(error)")
            throw error
        }
    }
}
