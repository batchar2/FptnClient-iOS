//
//  HomeView.swift
//  FptnVPN
//
//  Created by Stanislav on 15/6/2025.
//


import SwiftUI



struct HomeView: View {
    @State private var isConnected = false
    @State private var selectedMode = "Auto"
    @State private var connectionDuration = 5
    @State private var serverName = "USA–NewYork (🇺🇸)"
    @State private var downloadSpeed = "7,75 Kbps"
    @State private var uploadSpeed = "20,75 Kbps"
    
    var body: some View {
        VStack {
            Spacer()
            
            // Time
            if isConnected {
                Text("Время подключения")
                    .foregroundColor(.white)
                Text(String(format: "00:00:%02d", connectionDuration))
                    //.font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.bottom, 10)
            }
            
            // Кнопка включения
            Button(action: {
                withAnimation {
                    isConnected.toggle()
                    if isConnected {
                        connectionDuration = 0
                    }
                }
            }, label: {
                Image(isConnected ? "toggle_button_on" : "toggle_button_off")
                    .resizable()
                    .frame(width: 180, height: 180)
                    .padding()
            })
            
            // Status
            Text(isConnected ? "Подключено" : "Отключено")
                .foregroundColor(isConnected ? .yellow : .gray)
                .font(.headline)
                .padding(.bottom, 4)
            
            // Server
            if isConnected {
                Text("Сервер: \(serverName)")
                    .foregroundColor(.white)
                    .font(.subheadline)
                    .padding(.bottom, 20)
            }
            
            // Speed
            if isConnected {
                HStack {
                    Image(systemName: "arrow.down.to.line.alt")
                    Text(downloadSpeed)
                    Spacer()
                    Text(uploadSpeed)
                    Image(systemName: "arrow.up.to.line.alt")
                }
                .foregroundColor(.white)
                .padding()
                .background(Color.purple.opacity(0.3))
                .cornerRadius(20)
                .padding(.horizontal)
            }


            if !isConnected {
                Menu {
                    Button("Auto") { selectedMode = "Auto" }
                    Button("Manual") { selectedMode = "Manual" }
                } label: {
                    HStack {
                        Image(systemName: "shield")
                        Text(selectedMode)
                        Spacer()
                        Image(systemName: "chevron.down")
                    }
                    .padding()
                    .frame(height: 50)
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(radius: 2)
                }
                .padding(.horizontal)
            }
            Spacer()
            
            HStack {
                Spacer()
                VStack {
                    Image(systemName: "house")
                    Text("Главная")
                        .font(.caption)
                }
                Spacer()
                VStack {
                    Image(systemName: "gear")
                    Text("Настройки")
                        .font(.caption)
                }
                Spacer()
                VStack {
                    Image(systemName: "square.and.arrow.up")
                    Text("Поделиться")
                        .font(.caption)
                }
                Spacer()
            }
            .foregroundColor(.white)
            .padding()
            .background(Color.black.opacity(0.9))
        }
        .background(Color.appBackground)
        .edgesIgnoringSafeArea(.bottom)
    }
}

#Preview {
    HomeView()
}
