//
//  OfferShiftView.swift
//  Shift Radar
//
//  Created by Justin Lefrançois on 2023-10-24.
//

import SwiftUI

struct OfferShiftViewController: View {
    @StateObject private var viewModel = OfferShiftViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isEmpty {
                    NoShiftOfferView(showModal: $viewModel.showModal)
                } else {
                    OfferShiftView()
                }
            }
            .sheet(isPresented: $viewModel.showModal) {
                OfferShiftModalView()
                    .interactiveDismissDisabled()
                    .presentationDetents([.fraction(0.9), .fraction(0.96)])
            }
        }
        .environmentObject(viewModel)
    }
}

struct OfferShiftView: View {
    var body: some View {
        VStack {
            HStack {
                Button {
                    
                } label: {
                    Image(systemName: "line.3.horizontal.decrease")
                        .tint(.secondary)
                }
                Text("Sort by:")
                    .font(.system(size: 15, weight: .semibold))
                Button {
                    
                } label:{
                    Text("Date (more recent)")
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            ScrollView {
                VStack(spacing: 10) {  // 10 est l'espacement entre chaque ShiftView
                    ForEach(0..<10) { _ in  // Ceci affichera 10 ShiftViews
                        ShiftView()
                    }
                }
                .padding(1)
            }
        }
        .padding()
    }
}

struct NoShiftOfferView: View {
    @Binding var showModal: Bool
    
    var body: some View {
        VStack {
            Image("desert")
                .padding()
            Text("It's empty in here...".uppercased())
                .font(.title3)
                .fontWeight(.semibold)
                .padding(.vertical, 5)
            Text("You have no offered shifts yet")
                .font(.caption)
                .foregroundStyle(.secondary)
            Button {
                showModal = true
            } label: {
                Label("Offer shift", systemImage: "plus")
                    .transition(.identity)
                    .frame(maxWidth: .infinity)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .padding()
                    .background {
                        RoundedRectangle(cornerRadius: 18)
                            .fill(Color.accentColor)
                    }
                    .padding(.horizontal)
            }
            .padding()
        }
    }
}

#Preview {
    TabViewManager_Previews.PreviewWrapper(selectedTab: 0)
}
