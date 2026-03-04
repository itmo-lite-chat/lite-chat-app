import SwiftUI
import Combine

@MainActor
final class LoginViewModel: ObservableObject {
    @Published var username = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var errorMessage: String?

    func login(appState: AppState) async {
        guard !username.isEmpty, !password.isEmpty else {
            errorMessage = "Заполните все поля"
            return
        }
        isLoading = true
        errorMessage = nil
        do {
            let response = try await APIService.shared.login(username: username, password: password)
            appState.login(user: response.user)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}

struct LoginView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var vm = LoginViewModel()
    @FocusState private var focusedField: Field?

    enum Field { case username, password }

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // Logo
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.accentColor)
                            .frame(width: 80, height: 80)
                        Image(systemName: "message.fill")
                            .font(.system(size: 36))
                            .foregroundColor(.white)
                    }
                    Text("Lite Chat")
                        .font(.largeTitle.bold())
                    Text("Войдите, чтобы продолжить")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.bottom, 40)

                // Form
                VStack(spacing: 16) {
                    VStack(spacing: 0) {
                        HStack {
                            Image(systemName: "person")
                                .foregroundStyle(.secondary)
                                .frame(width: 24)
                            TextField("Имя пользователя", text: $vm.username)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .focused($focusedField, equals: .username)
                                .submitLabel(.next)
                                .onSubmit { focusedField = .password }
                        }
                        .padding()

                        Divider().padding(.leading, 52)

                        HStack {
                            Image(systemName: "lock")
                                .foregroundStyle(.secondary)
                                .frame(width: 24)
                            SecureField("Пароль", text: $vm.password)
                                .focused($focusedField, equals: .password)
                                .submitLabel(.go)
                                .onSubmit {
                                    Task { await vm.login(appState: appState) }
                                }
                        }
                        .padding()
                    }
                    .background(.background)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    if let error = vm.errorMessage {
                        HStack(spacing: 6) {
                            Image(systemName: "exclamationmark.circle.fill")
                            Text(error)
                        }
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 4)
                    }

                    Button {
                        Task { await vm.login(appState: appState) }
                    } label: {
                        ZStack {
                            if vm.isLoading {
                                ProgressView().tint(.white)
                            } else {
                                Text("Войти")
                                    .font(.headline)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .disabled(vm.isLoading)
                }
                .padding(.horizontal, 24)

                Spacer()

                Text("Подсказка: demo / password")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .padding(.bottom, 16)
            }
        }
        .onTapGesture { focusedField = nil }
    }
}

#Preview {
    LoginView()
        .environmentObject(AppState())
}
