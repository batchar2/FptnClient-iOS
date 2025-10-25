/*=============================================================================
Copyright (c) 2024-2025 Stas Skokov

Distributed under the MIT License (https://opensource.org/licenses/MIT)
=============================================================================*/

import SwiftUI

struct HomeView: View {
    @StateObject private var vpnService = VPNService()
    @State private var showingServerList = false
    
    var body: some View {
        VStack {
            Spacer()
            
            // Connection time
            if vpnService.connection.isConnected {
//                var name = "111"
//                name = "1111"
//                
//                let a = 1;
//                a = 5
//                let colors = [1,2,3, "111"]
                Text("Connection Time")
                    .foregroundColor(.white)
                Text(vpnService.formatConnectionTime())
                    .foregroundColor(.white)
                    .padding(.bottom, 10)
            }
            
            // Toggle button
            Button(action: {
                withAnimation {
                    if vpnService.connection.isConnected {
                        vpnService.disconnect()
                    } else {
                        vpnService.connect()
                    }
                }
            }, label: {
                Image(vpnService.connection.isConnected ? "toggle_button_on" : "toggle_button_off")
                    .resizable()
                    .frame(width: 180, height: 180)
                    .padding()
            }).padding(.top, -200)
            
            // Status
            Text(vpnService.connection.isConnected ? "Connected" : "Disconnected")
                .foregroundColor(vpnService.connection.isConnected ? .yellow : .gray)
                .font(.headline)
                .padding(.bottom, 4)
            
            // Server
            if vpnService.connection.isConnected, let server = vpnService.connection.selectedServer {
                Text("Server: \(server.name)")
                    .foregroundColor(.white)
                    .font(.subheadline)
                    .padding(.bottom, 20)
            }
            
            // Speed
            if vpnService.connection.isConnected {
                HStack {
                    Image(systemName: "arrow.down.to.line.alt")
                    Text(vpnService.formatSpeed(vpnService.connection.downloadSpeed))
                    Spacer()
                    Text(vpnService.formatSpeed(vpnService.connection.uploadSpeed))
                    Image(systemName: "arrow.up.to.line.alt")
                }
                .foregroundColor(.white)
                .padding()
                .background(Color.purple.opacity(0.3))
                .cornerRadius(20)
                .padding(.horizontal)
            }

            if !vpnService.connection.isConnected {
                Button(action: {
                    showingServerList = true
                }) {
                    HStack {
                        Image(systemName: "shield")
                        Text(serverSelectionText)
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
                .sheet(isPresented: $showingServerList) {
                    ServerListView(vpnService: vpnService)
                }
            }
            
            Spacer()
            
            // Bottom navigation
            HStack {
                Spacer()
                VStack {
                    Image(systemName: "house.fill")
                    Text("Home")
                        .font(.caption)
                }
                Spacer()
                VStack {
                    Image(systemName: "gear")
                    Text("Settings")
                        .font(.caption)
                }
                Spacer()
                VStack {
                    Image(systemName: "square.and.arrow.up")
                    Text("Share")
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
    
    private var serverSelectionText: String {
        switch vpnService.connection.connectionMode {
        case .auto:
            return "Auto"
        case .manual(let server):
            return server.name
        }
    }
}

#Preview {
    HomeView()
}
