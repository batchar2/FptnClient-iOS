//
//  ContentView.swift
//  FptnVPN
//
//  Created by Stanislav on 14/6/2025.
//

import SwiftUI
import Observation


@Observable class TokenValidator {
    var token = ""
    
    var isLoginButtonDisabled: Bool {
        token.isEmpty
    }
    
    func isValidToken(string: String) -> Bool {
        return true;
    }
}

struct LoginView: View {
    @State private var tokenValidator = TokenValidator()

    var body: some View {
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
                    // handle login
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
                Spacer()
            }
        }
    }
}

#Preview {
    @Previewable @State var tokenValidator = TokenValidator()
    LoginView()
}
