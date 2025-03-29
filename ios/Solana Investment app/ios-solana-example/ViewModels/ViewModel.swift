import SwiftUI
import Web3Auth

class ViewModel: ObservableObject {
    @Published var isLoggedIn = false
    @Published var userInfo: Web3AuthUserInfo?
    
    func login() {
        // Web3Auth login will be implemented in Web3AuthHelper
        isLoggedIn = true
    }
    
    func logout() {
        isLoggedIn = false
        userInfo = nil
    }
} 