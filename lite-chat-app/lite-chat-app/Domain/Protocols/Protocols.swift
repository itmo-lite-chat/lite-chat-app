import Foundation

protocol AuthRepositoryProtocol {
    func login(username: String, password: String) async throws -> User
}

protocol ChatRepositoryProtocol {
    func fetchChats(token: String) async throws -> [Chat]
    func createPrivateChat(username: String, token: String) async throws -> Chat
    func deleteChat(chatId: String, token: String) async throws
}

protocol MessageRepositoryProtocol {
    func fetchMessages(chatId: String, token: String) async throws -> [Message]
    func sendMessage(chatId: String, text: String, token: String) async throws -> Message
    func editMessage(chatId: String, messageId: String, text: String, token: String) async throws -> Message
    func deleteMessage(chatId: String, messageId: String, token: String) async throws
}
