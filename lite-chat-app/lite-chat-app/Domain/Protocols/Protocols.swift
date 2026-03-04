import Foundation

protocol AuthRepositoryProtocol {
    func login(username: String, password: String) async throws -> User
}

protocol ChatRepositoryProtocol {
    func fetchChats(token: String) async throws -> [Chat]
}

protocol MessageRepositoryProtocol {
    func fetchMessages(chatId: String, token: String) async throws -> [Message]
    func sendMessage(chatId: String, text: String, token: String) async throws -> Message
}
