import Foundation
import SolanaSwift

class SolanaViewModel: ObservableObject {
    @Published var balance: Double = 0.0
    private var apiClient: JSONRPCAPIClient?
    
    init() {
        setupSolanaClient()
    }
    
    private func setupSolanaClient() {
        let endpoint = APIEndPoint(
            address: "https://api.mainnet-beta.solana.com",
            network: .mainnetBeta
        )
        apiClient = JSONRPCAPIClient(endpoint: endpoint)
    }
    
    func fetchBalance(for account: Account) async {
        do {
            let balance = try await apiClient?.getBalance(account: account)
            DispatchQueue.main.async {
                self.balance = Double(balance ?? 0) / 1_000_000_000 // Convert lamports to SOL
            }
        } catch {
            print("Error fetching balance: \(error)")
        }
    }
} 