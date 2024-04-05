//
//  RequestShiftView.swift
//  Shift Radar
//
//  Created by Justin Lefrançois on 2023-10-24.
//

import SwiftUI

struct RequestShiftView: View {
    @StateObject private var viewModel = RequestShiftViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isLoadingShifts {
                    ProgressView()
                } else if !viewModel.userShiftsWithOffers.isEmpty {
                    OffersListView()
                } else {
                    Text("You have no offers right now")
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.background)
        }
        .environmentObject(viewModel)
    }
}

struct OffersListView: View {
    @EnvironmentObject var viewModel: RequestShiftViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ForEach($viewModel.userShiftsWithOffers) { $shift in
                    ShiftView(shift: $shift)
                        .showOffers()
                        .onTap {
                            // TODO
//                            if (shift.offersRef?.count ?? 0) != 0 {
//                                viewModel.selectShiftForReview(shift)
//                            } else {
//                                
//                            }
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
