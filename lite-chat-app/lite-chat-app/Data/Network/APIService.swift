import Foundation

final class APIService: AuthRepositoryProtocol, ChatRepositoryProtocol, MessageRepositoryProtocol {
    static let shared = APIService()

    #if DEBUG
    private let baseURL = URL(string: "http://localhost:18080")!
    #else
    private let baseURL = URL(string: "https://api.lite-chat.example")!
    #endif

    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    private init(session: URLSession = .shared) {
        self.session = session

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        self.decoder = decoder

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        self.encoder = encoder
    }

    func login(username: String, password: String) async throws -> User {
        let request = try makeRequest(
            path: "/api/auth/login",
            method: "POST",
            body: LoginRequest(username: username, password: password)
        )
        let response: LoginResponse = try await send(request, unauthorizedError: .invalidCredentials)
        return response.user
    }

    func fetchChats(token: String) async throws -> [Chat] {
        let request = try makeRequest(path: "/api/chats", token: token)
        let response: ChatsResponse = try await send(request)
        return response.chats
    }

    func createPrivateChat(username: String, token: String) async throws -> Chat {
        let request = try makeRequest(
            path: "/api/chats/private",
            method: "POST",
            token: token,
            body: PrivateChatRequest(username: username)
        )
        let response: PrivateChatResponse = try await send(request)
        return response.chat
    }

    func deleteChat(chatId: String, token: String) async throws {
        let request = try makeRequest(path: "/api/chats/\(chatId)", method: "DELETE", token: token)
        try await sendWithoutBody(request)
    }

    func fetchMessages(chatId: String, token: String) async throws -> [Message] {
        let request = try makeRequest(path: "/api/chats/\(chatId)/messages", token: token)
        let response: MessagesResponse = try await send(request)
        return response.messages
    }

    func sendMessage(chatId: String, text: String, token: String) async throws -> Message {
        let request = try makeRequest(
            path: "/api/chats/\(chatId)/messages",
            method: "POST",
            token: token,
            body: SendMessageRequest(body: text)
        )
        let response: SendMessageResponse = try await send(request)
        return response.message
    }

    func editMessage(chatId: String, messageId: String, text: String, token: String) async throws -> Message {
        let request = try makeRequest(
            path: "/api/chats/\(chatId)/messages/\(messageId)",
            method: "PATCH",
            token: token,
            body: EditMessageRequest(body: text)
        )
        let response: EditMessageResponse = try await send(request)
        return response.message
    }

    func deleteMessage(chatId: String, messageId: String, token: String) async throws {
        let request = try makeRequest(
            path: "/api/chats/\(chatId)/messages/\(messageId)",
            method: "DELETE",
            token: token
        )
        try await sendWithoutBody(request)
    }

    private func makeRequest<T: Encodable>(
        path: String,
        method: String = "GET",
        token: String? = nil,
        body: T
    ) throws -> URLRequest {
        var request = URLRequest(url: url(for: path))
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        if let token, !token.isEmpty {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try encoder.encode(body)

        return request
    }

    private func makeRequest(
        path: String,
        method: String = "GET",
        token: String? = nil
    ) throws -> URLRequest {
        var request = URLRequest(url: url(for: path))
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        if let token, !token.isEmpty {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        return request
    }

    private func url(for path: String) -> URL {
        let normalizedPath = path.hasPrefix("/") ? String(path.dropFirst()) : path
        return baseURL.appendingPathComponent(normalizedPath)
    }

    private func send<T: Decodable>(
        _ request: URLRequest,
        unauthorizedError: APIError = .unauthorized
    ) async throws -> T {
        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.networkError
        }

        switch httpResponse.statusCode {
        case 200..<300:
            return try decoder.decode(T.self, from: data)
        case 401:
            throw unauthorizedError
        case 400..<500:
            throw clientError(from: data)
        default:
            throw APIError.networkError
        }
    }

    private func sendWithoutBody(_ request: URLRequest) async throws {
        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.networkError
        }

        switch httpResponse.statusCode {
        case 200..<300:
            return
        case 401:
            throw APIError.unauthorized
        case 400..<500:
            throw clientError(from: data)
        default:
            throw APIError.networkError
        }
    }

    private func clientError(from data: Data) -> APIError {
        if let response = try? decoder.decode(ErrorResponse.self, from: data), !response.error.isEmpty {
            return .requestFailed(response.error)
        }
        return .networkError
    }
}
