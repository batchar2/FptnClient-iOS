/*=============================================================================
Copyright (c) 2024-2025 Stas Skokov

Distributed under the MIT License (https://opensource.org/licenses/MIT)
=============================================================================*/

import SwiftUI

struct ServerListView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var vpnService: VPNService
    
    private let serverService = ServerSelectionService.shared
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Режим подключения")) {
                    Button(action: {
                        vpnService.connection.connectionMode = .auto
                        dismiss()
                    }) {
                        HStack {
                            Text("Auto")
                            Spacer()
                            if case .auto = vpnService.connection.connectionMode {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
                
                Section(header: Text("Серверы")) {
                    ForEach(serverService.getAllServers()) { server in
                        Button(action: {
                            vpnService.connection.connectionMode = .manual(server)
                            dismiss()
                        }) {
                            HStack {
                                Text(server.name)
                                Spacer()
                                if case .manual(let selectedServer) = vpnService.connection.connectionMode,
                                   selectedServer.id == server.id {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Выбор сервера")
            .navigationBarItems(trailing: Button("Готово") {
                dismiss()
            })
        }
    }
}
