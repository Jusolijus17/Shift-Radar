//
//  StaffView.swift
//  Shift Radar
//
//  Created by Justin Lefrançois on 2023-10-24.
//

import SwiftUI

struct StaffView: View {
    @ObservedObject var viewModel = StaffViewModel()
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 10) {
                ForEach(viewModel.users, id: \.id) { user in
                    UserCell(user: .constant(user))
                }
                
                if viewModel.isLoading {
                    ProgressView()
                }
            }
            .padding()
            .onAppear {
                if viewModel.users.isEmpty {
                    viewModel.loadUsers()
                }
            }
            .onReachBottom(perform: {
                viewModel.loadUsers()
            })
        }
    }
}

extension View {
    func onReachBottom(perform action: @escaping () -> Void) -> some View {
        self.onAppear {
            NotificationCenter.default.addObserver(forName: Notification.Name("onReachBottom"), object: nil, queue: .main) { _ in
                action()
            }
        }
    }
}

#Preview {
    TabViewManager_Previews.PreviewWrapper(selectedTab: 3)
}
