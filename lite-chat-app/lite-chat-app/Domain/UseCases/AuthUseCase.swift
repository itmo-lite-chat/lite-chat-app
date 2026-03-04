import Foundation

final class AuthUseCase {
    private let repository: AuthRepositoryProtocol

    init(repository: AuthRepositoryProtocol) {
        self.repository = repository
    }

    func execute(username: String, password: String) async throws -> User {
        try await repository.login(username: username, password: password)
    }
}
