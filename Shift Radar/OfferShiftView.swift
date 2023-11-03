//
//  OfferShiftView.swift
//  Shift Radar
//
//  Created by Justin Lefrançois on 2023-10-24.
//

import SwiftUI

struct OfferShiftView: View {
    var body: some View {
        VStack {
            Image("desert")
                .padding()
            Text("It's empty in here...")
                .font(.title2)
                .fontWeight(.semibold)
            Text("You have no offered shifts yet")
                .font(.caption2)
        }
    }
}

#Preview {
    TabViewManager_Previews.previews
}
