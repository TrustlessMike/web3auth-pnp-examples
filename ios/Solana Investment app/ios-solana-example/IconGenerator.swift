import SwiftUI

struct IconGenerator: View {
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                gradient: Gradient(colors: [Color.blue, Color.purple]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Solana Logo
            Text("S")
                .font(.system(size: 60, weight: .bold))
                .foregroundColor(.white)
        }
        .frame(width: 1024, height: 1024)
    }
}

#Preview {
    IconGenerator()
} 