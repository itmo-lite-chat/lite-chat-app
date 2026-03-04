import SwiftUI
import Combine

@MainActor
final class ChatsViewModel: ObservableObject {
    @Published var chats: [Chat] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let chatsUseCase: ChatsUseCase

    init() {
        self.chatsUseCase = DIContainer.shared.chatsUseCase
    }

    func fetchChats(token: String) async {
        isLoading = true
        errorMessage = nil
        do {
            chats = try await chatsUseCase.execute(token: token)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
