import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var viewModel: ViewModel
    @StateObject private var solanaViewModel = SolanaViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                if let userInfo = viewModel.userInfo {
                    Text("Welcome, \(userInfo.email ?? "User")")
                        .font(.title)
                        .padding()
                }
                
                // Solana-specific UI will be added here
                Text("Solana Balance: \(solanaViewModel.balance) SOL")
                    .font(.headline)
                    .padding()
                
                Button("Logout") {
                    viewModel.logout()
                }
                .padding()
            }
            .navigationTitle("Solana Investment App")
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(ViewModel())
} 