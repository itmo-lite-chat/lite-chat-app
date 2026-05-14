import SwiftUI
import Combine

@MainActor
final class AppState: ObservableObject {
    @Published var currentUser: User?
    @Published var isLoggedIn = false

    func login(user: User) {
        currentUser = user
        isLoggedIn = true
    }

    func logout() {
        currentUser = nil
        isLoggedIn = false
    }
}
