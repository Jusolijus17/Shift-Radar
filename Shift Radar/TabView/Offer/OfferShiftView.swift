//
//  OfferShiftView.swift
//  Shift Radar
//
//  Created by Justin Lefrançois on 2023-10-24.
//

import SwiftUI

struct OfferShiftViewController: View {
    @StateObject private var viewModel = OfferShiftViewModel()
    
    @State var currentDetent: PresentationDetent = .fraction(0.8)
    @State var availableDetents: Set<PresentationDetent> = [.fraction(0.8), .medium]
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.offeredShifts.isEmpty {
                    NoShiftOfferView(showModal: $viewModel.showModal)
                } else {
                    OfferShiftView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(hex: "#F2F2F2"))
            .sheet(isPresented: $viewModel.showModal) {
                OfferShiftModalView()
                    .interactiveDismissDisabled()
                    .presentationDetents(availableDetents, selection: $currentDetent)
                    .onAppear {
                        viewModel.loadMenuOptionsIfNeeded()
                    }
                    .onChange(of: viewModel.confirmOffer) { _, newValue in
                        if newValue == true {
                            currentDetent = .medium
                        } else {
                            currentDetent = .fraction(0.8)
                        }
                    }
            }
        }
        .environmentObject(viewModel)
    }
}

struct OfferShiftView: View {
    @EnvironmentObject var viewModel: OfferShiftViewModel
    var body: some View {
        VStack {
            HStack {
                Button {
                    
                } label: {
                    Image(systemName: "line.3.horizontal.decrease")
                        .tint(.secondary)
                }
                Text("Sort by:")
                    .font(.system(size: 20, weight: .semibold))
                Menu {
                    Button("Date (more recent)", action: {})
                } label: {
                    Button("Date (more recent)", action: {})
                }
            }
            .padding([.horizontal, .top])
            .frame(maxWidth: .infinity, alignment: .leading)
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(0..<viewModel.offeredShifts.count, id: \.self) { index in
                        ShiftView(hasOffer: .constant(index.isMultiple(of: 2) ? true : false), shift: $viewModel.offeredShifts[index], onDelete: { id in
                            viewModel.deleteShift(id)
                        })
                            .padding(.horizontal)
                    }
                }
                .padding(.top, 15)
                .padding(1)
                
                Button {
                    viewModel.showModal = true
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
                }
                .sensoryFeedback(.impact, trigger: viewModel.showModal)
                .padding([.horizontal, .top])
                
                Button {
                    
                } label: {
                    Text("Show past shifts")
                        .underline()
                }

            }
        }
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

import FirebaseAuth

#Preview {
    TabViewManager_Previews.PreviewWrapper(selectedTab: 0)
        .onAppear {
            Auth.auth().signIn(withEmail: "testaccount@aircanada.ca", password: "Bosesony2011")
        }
}
