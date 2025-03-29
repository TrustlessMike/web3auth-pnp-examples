import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Solana Investment App")
                .font(.largeTitle)
                .padding(.top, 50)
            
            if viewModel.isLoggedIn {
                VStack(spacing: 20) {
                    if let userInfo = viewModel.userInfo {
                        Text("Welcome,")
                            .font(.title)
                        Text(userInfo.email ?? "")
                            .font(.title2)
                    }
                    
                    Text("Solana Balance: \(String(format: "%.6f", viewModel.solanaViewModel.balance)) SOL")
                        .font(.title2)
                    
                    if viewModel.solanaViewModel.isLoading {
                        ProgressView()
                    }
                    
                    // Faucet and Test Transaction Buttons
                    VStack(spacing: 15) {
                        Button(action: {
                            Task {
                                await viewModel.solanaViewModel.requestAirdrop()
                            }
                        }) {
                            Text("Request 1 SOL from Faucet")
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                        
                        Button(action: {
                            Task {
                                await viewModel.solanaViewModel.sendTestTransaction()
                            }
                        }) {
                            Text("Send Test Transaction")
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal)
                    
                    if let error = viewModel.solanaViewModel.error {
                        Text(error)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                    
                    Spacer()
                    
                    Button("Logout") {
                        viewModel.logout()
                    }
                    .foregroundColor(.blue)
                    .padding(.bottom, 30)
                }
            } else {
                Spacer()
                Button("Login with Google") {
                    viewModel.login()
                }
                .foregroundColor(.blue)
                Spacer()
            }
        }
    }
}

#Preview {
    ContentView()
} 