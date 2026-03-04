import Foundation

protocol AuthRepositoryProtocol {
    func login(username: String, password: String) async throws -> User
}

protocol ChatRepositoryProtocol {
    func fetchChats(token: String) async throws -> [Chat]
}
