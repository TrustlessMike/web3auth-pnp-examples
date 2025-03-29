//
//  ContentView.swift
//  Solana Investment app
//
//  Created by Ayush B on 26/02/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel: ViewModel
    
    var body: some View {
        NavigationView {
            if viewModel.isUserAuthenticated {
                HomeView(
                    solanaViewModel: SolanaViewModel(),
                    viewModel: viewModel
                )
            } else {
                LoginView(viewModel: viewModel)
            }
        }.onAppear{
            viewModel.initialize()
        }
    }
}

#Preview {
    ContentView(viewModel: ViewModel())
}
