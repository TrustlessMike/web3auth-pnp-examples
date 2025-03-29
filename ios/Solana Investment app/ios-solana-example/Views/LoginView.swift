import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var viewModel: ViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Solana Investment App")
                .font(.largeTitle)
                .padding()
            
            Text("Welcome to the future of decentralized investments")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding()
            
            Button(action: {
                viewModel.login()
            }) {
                Text("Login with Web3Auth")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
        }
        .padding()
    }
}

#Preview {
    LoginView()
        .environmentObject(ViewModel())
} 