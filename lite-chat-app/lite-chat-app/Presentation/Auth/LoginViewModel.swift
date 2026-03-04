import SwiftUI
import Combine

@MainActor
final class LoginViewModel: ObservableObject {
    @Published var username = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let authUseCase: AuthUseCase

    init() {
        self.authUseCase = DIContainer.shared.authUseCase
    }

    func login(appState: AppState) async {
        guard !username.isEmpty, !password.isEmpty else {
            errorMessage = "Заполните все поля"
            return
        }
        isLoading = true
        errorMessage = nil
        do {
            let user = try await authUseCase.execute(username: username, password: password)
            appState.login(user: user)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
