import SwiftUI
import Observation


@Observable class TokenValidator {
    var token = ""
    var errorMessage: String?
    var isLoggedIn = false
    
    var isLoginButtonDisabled: Bool {
        token.isEmpty
    }
    
    func handleLogin() {
        guard token.hasPrefix("fptn:") else {
            errorMessage = "Invalid token format. Token should start with 'fptn:'"
            return
        }
        
        let base64String = String(token.dropFirst(5))
        let paddedBase64String = addBase64Padding(base64String)
        
        guard let data = Data(base64Encoded: paddedBase64String) else {
            errorMessage = "Invalid base64 encoding"
            return
        }
        
        do {
            let tokenData = try JSONDecoder().decode(FPTNToken.self, from: data)
            TokenService.shared.saveTokenData(tokenData)
            isLoggedIn = true
        } catch {
            errorMessage = "Failed to parse token: \(error.localizedDescription)"
        }
    }
    
    private func addBase64Padding(_ base64String: String) -> String {
        var paddedString = base64String
        let remainder = base64String.count % 4
        
        if remainder > 0 {
            paddedString += String(repeating: "=", count: 4 - remainder)
        }
        
        return paddedString
    }
}

struct LoginView: View {
    @State private var tokenValidator = TokenValidator()
    @State private var showingAlert = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Фоновый цвет
                Color(Color.appBackground)
                    .edgesIgnoringSafeArea(.all)

                VStack(spacing: 32) {
                    Spacer()

                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                        .foregroundColor(.white)

                    HStack(spacing: 0) {
                        Text("Use the Telegram-bot ")
                            .foregroundColor(.white)
                        
                        Link("@fptn_bot", destination: URL(string: AppLinks.telegramBot)!)
                            .foregroundColor(Color.cian)
                            .underline()
                        
                        Text(" to get a token")
                            .foregroundColor(.white)
                    }

                    TextField("Paste your token here...", text: $tokenValidator.token)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(24)
                        .padding(.horizontal, 15)
                        .foregroundColor(.black)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)

                    Button(action: {
                        tokenValidator.handleLogin()
                        if tokenValidator.errorMessage != nil {
                            showingAlert = true
                        }
                    }) {
                        Text("Login")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(tokenValidator.isLoginButtonDisabled ? Color.gray : Color.cian)
                            .foregroundColor(.white)
                            .cornerRadius(24)
                            .padding(.horizontal, 15)
                    }
                    .disabled(tokenValidator.isLoginButtonDisabled)
                    .alert("Error", isPresented: $showingAlert) {
                        Button("OK", role: .cancel) { }
                    } message: {
                        Text(tokenValidator.errorMessage ?? "Unknown error")
                    }
                    Spacer()
                }
            }
            .navigationDestination(isPresented: $tokenValidator.isLoggedIn) {
                HomeView()
            }
        }
    }
}

#Preview {
    LoginView()
}
