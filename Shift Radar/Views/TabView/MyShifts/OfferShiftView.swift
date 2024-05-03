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
    @State var availableDetents: Set<PresentationDetent> = [.fraction(0.8), .fraction(0.5)]
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isLoadingShifts {
                    ProgressView()
                } else if viewModel.offeredShifts.isEmpty {
                    NoShiftOfferView(showModal: $viewModel.showEditModal)
                } else {
                    OfferShiftView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.background)
            .sheet(isPresented: $viewModel.showEditModal) {
                OfferShiftModalView(shift: viewModel.selectedShift, isEditing: viewModel.isEditingShift)
                    .interactiveDismissDisabled()
                    .presentationDetents(availableDetents, selection: $currentDetent)
                    .onDisappear {
                        viewModel.prepareNewShift()
                        currentDetent = .fraction(0.8)
                    }
                    .onChange(of: viewModel.confirmOffer) { _, newValue in
                        if newValue == true {
                            currentDetent = .fraction(0.5)
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
            
            ZStack(alignment: .bottomTrailing) {
                ScrollView {
                    VStack(spacing: 10) {
                        ForEach($viewModel.offeredShifts) { $shift in
                            ShiftCell(shift: $shift)
                                .showMoreActions()
                                .onDelete {
                                    viewModel.deleteShift(shift)
                                }
                                .onEdit {
                                    viewModel.selectShiftForEditing(shift)
                                }
                                .padding(.horizontal)
                                .alert(isPresented: $viewModel.showAlert, content: {
                                    Alert(
                                        title: Text(self.viewModel.error?.title ?? "Error"),
                                        message: Text(self.viewModel.error?.message ?? "Unknown error"),
                                        dismissButton: .default(Text("OK")))
                                })
                        }
                    }
                    .padding(.top, 15)
                    .padding(1)
                    
                    Button {
                        
                    } label: {
                        Text("Show past shifts")
                            .underline()
                    }
                    .padding(.bottom, 80)
                    
                }
                .refreshable {
                    await viewModel.refreshShifts()
                }
                
                Button {
                    viewModel.showEditModal = true
                } label: {
                    Label("Offer shift", systemImage: "plus")
                        .transition(.identity)
                        .frame(width: 150)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .padding()
                        .background {
                            RoundedRectangle(cornerRadius: 18)
                                .fill(Color.accentColor)
                        }
                        .shadow(radius: 3)
                }
                .sensoryFeedback(.impact, trigger: viewModel.showEditModal)
                .padding([.horizontal, .bottom])
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
            Auth.auth().signIn(withEmail: "testaccount2@aircanada.ca", password: "Bosesony")
        }
}
