import Foundation

final class APIService: AuthRepositoryProtocol, ChatRepositoryProtocol, MessageRepositoryProtocol {
    static let shared = APIService()
    private init() {}

    private let baseURL = "https://api.lite-chat.example"

    func login(username: String, password: String) async throws -> User {
        return User(id: "", username: "", displayName: "", token: "")
    }

    func fetchChats(token: String) async throws -> [Chat] {
        return []
    }

    func fetchMessages(chatId: String, token: String) async throws -> [Message] {
        return []
    }

    func sendMessage(chatId: String, text: String, token: String) async throws -> Message {
        return Message(id: "", senderId: "", text: "", timestamp: Date())
    }
}
