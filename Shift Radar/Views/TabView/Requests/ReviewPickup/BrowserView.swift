//
//  BrowserView.swift
//  Shift Radar
//
//  Created by Justin Lefrançois on 2024-04-06.
//

import SafariServices
import SwiftUI

struct BrowserView: UIViewControllerRepresentable {
    var url: URL

        func makeUIViewController(context: Context) -> SFSafariViewController {
            SFSafariViewController(url: url)
        }

        func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {
        }
}

#Preview {
    VStack {
        Text("Browser view")
            .sheet(isPresented: .constant(true)) {
                BrowserView(url: URL(string: "https://google.com")!)
                    .ignoresSafeArea()
            }
    }
}
