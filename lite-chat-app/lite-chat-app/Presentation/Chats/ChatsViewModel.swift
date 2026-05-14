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

    func fetchChats(token: String, showLoading: Bool = true) async {
        if showLoading {
            isLoading = true
        }
        errorMessage = nil
        do {
            chats = try await chatsUseCase.execute(token: token)
        } catch {
            errorMessage = error.localizedDescription
        }
        if showLoading {
            isLoading = false
        }
    }

    func refreshChats(token: String) async {
        await fetchChats(token: token, showLoading: false)
    }

    func createPrivateChat(username: String, token: String) async -> Chat? {
        let trimmedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedUsername.isEmpty else { return nil }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let chat = try await chatsUseCase.createPrivateChat(username: trimmedUsername, token: token)
            chats = try await chatsUseCase.execute(token: token)
            return chat
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }

    func deleteChat(_ chat: Chat, token: String) async {
        errorMessage = nil

        do {
            try await chatsUseCase.deleteChat(chatId: chat.id, token: token)
            chats.removeAll { $0.id == chat.id }
        } catch {
            errorMessage = error.localizedDescription
            await refreshChats(token: token)
        }
    }

    func clear() {
        chats = []
        errorMessage = nil
        isLoading = false
    }
}
