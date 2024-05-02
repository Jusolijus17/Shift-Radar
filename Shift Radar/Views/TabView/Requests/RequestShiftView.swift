//
//  RequestShiftView.swift
//  Shift Radar
//
//  Created by Justin Lefrançois on 2023-10-24.
//

import SwiftUI

struct RequestShiftView: View {
    @StateObject private var viewModel = RequestShiftViewModel()
    @State var detentHeight: CGFloat = 0
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isLoadingShifts {
                    ProgressView()
                } else if !viewModel.userShiftsWithOffers.isEmpty {
                    OffersListView()
                } else {
                    ZStack {
                        Text("You have no offers right now")
                            .foregroundStyle(.secondary)
                        ScrollView { }
                            .refreshable {
                                await viewModel.reloadDataAsync()
                            }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.background)
            .sheet(isPresented: $viewModel.showReviewModal) {
                ReviewPickupModalView(shift: viewModel.selectedShift, offers: $viewModel.shiftOffers)
                    .readHeight()
                    .onPreferenceChange(HeightPreferenceKey.self, perform: { height in
                        if let height {
                            self.detentHeight = height
                        }
                    })
                    .presentationDetents([.height(self.detentHeight)])
                    .alert(isPresented: $viewModel.showAlert, content: {
                        Alert(
                            title: Text(self.viewModel.error?.title ?? "Error"),
                            message: Text(self.viewModel.error?.message ?? "Unknown error"),
                            dismissButton: .default(Text("OK")) {
                                viewModel.showReviewModal.toggle()
                            })
                    })
                    .onDisappear {
                        self.detentHeight = 0
                    }
            }
        }
        .environmentObject(viewModel)
    }
}

struct OffersListView: View {
    @EnvironmentObject var viewModel: RequestShiftViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                ForEach($viewModel.userShiftsWithOffers) { $shift in
                    ShiftCell(shift: $shift)
                        .showOffers()
                        .onTap {
                            if (shift.offersRef?.count ?? 0) != 0 {
                                viewModel.selectShiftForReview(shift)
                            }
                        }
                        .padding(.top, 15)
                        .padding(.horizontal)
                }
            }
        }
        .refreshable {
            await viewModel.reloadDataAsync()
        }
        .padding(.top)
    }
}

#Preview {
    TabViewManager_Previews.PreviewWrapper(selectedTab: 2)
}
