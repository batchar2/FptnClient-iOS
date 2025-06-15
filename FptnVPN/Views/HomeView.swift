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
    
    var body: some View {
        VStack {
            Spacer()
                        
            // Power button icon
            Image(systemName: "power")
                .resizable()
                .frame(width: 120, height: 120)
                .foregroundColor(isConnected ? .green : .gray)
                .padding()
                .onTapGesture {
                    withAnimation {
                        isConnected.toggle()
                    }
                }
                        
            // Connection status text
            Text(isConnected ? "Connected" : "Disconnected")
                .foregroundColor(isConnected ? .green : .yellow)
                .font(.headline)
                .padding(.bottom, 40)
                        
            // Dropdown menu for mode selection
            Menu {
                Button("Auto") { selectedMode = "Auto" }
                Button("Manual") { selectedMode = "Manual" }
                // Add more options if needed
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
                    
            Spacer()
                        
            // Bottom navigation bar
            HStack {
                Spacer()
                
                VStack {
                    Image(systemName: "house")
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
        .background(Color.appBackground) // Dark purple background
        .edgesIgnoringSafeArea(.bottom)
    }
}

#Preview {
    HomeView()
}
