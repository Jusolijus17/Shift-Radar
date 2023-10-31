//
//  EmailConfirmView.swift
//  Shift Radar
//
//  Created by Justin Lefrançois on 2023-10-26.
//

import SwiftUI

struct EmailConfirmView: View {
    var body: some View {
        Text("We just sent an email verification link to your inbox. Click on the link to verifiy your email and you'll be all set!")
            .font(.caption)
            .foregroundStyle(.tertiary)
            .multilineTextAlignment(.center)
            .frame(maxWidth: 250)
        Button {
            
        } label: {
            Text("Resend verification link")
                .underline()
        }
        .padding(.top)
    }
}

#Preview {
    EmailConfirmView()
}
