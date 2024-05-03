//
//  PickupShiftViewModal.swift
//  Shift Radar
//
//  Created by Justin Lefrançois on 2023-12-23.
//

import SwiftUI
import UIKit

struct ReviewRequestModalView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel: ReviewRequestModalViewModel
    @State private var selectedOffer = 0
    
    @State var shift: Shift
    @Binding var offers: [Offer]
    
    init(shouldReloadRequests: Binding<Bool>, shift: Shift, offers: Binding<[Offer]>) {
        self.shift = shift
        _offers = offers
        _viewModel = StateObject(wrappedValue: ReviewRequestModalViewModel(shouldReloadRequests: shouldReloadRequests))
    }
    
    var body: some View {
        VStack {
            ZStack {
                Text("OFFER DETAILS")
                    .font(.title3)
                    .bold()
                    .padding(.top)
                
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .foregroundStyle(Color.gray)
                        .padding(8)
                        .background {
                            Circle()
                                .fill(Color(uiColor: .secondarySystemBackground))
                        }
                        .padding([.top, .trailing])
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
            
            if viewModel.offers.count != 0 && !viewModel.userDatas.isEmpty {
                HeightPreservingTabView(selection: $selectedOffer) {
                    ForEach(viewModel.offers.indices, id: \.self) { index in
                        let offer = viewModel.offers[index]
                        if let userData = viewModel.userDatas[offer.from ?? ""] {
                            OfferView(shift: self.shift, offer: offer, userData: userData)
                                .tag(index)
                        }
                    }
                }
                .environmentObject(viewModel)
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
            } else {
                ProgressView()
                    .frame(height: 100)
            }
            
            if viewModel.offers.isEmpty || viewModel.offers[selectedOffer].status != .declined {
                HStack(spacing: 15) {
                    Button {
                        print("Selected offer: ", viewModel.offers[selectedOffer])
                        viewModel.declineOffer(at: selectedOffer)
                    } label: {
                        Label("Decline", systemImage: "xmark")
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 30)
                            .background {
                                RoundedRectangle(cornerRadius: 15)
                                    .foregroundStyle(viewModel.offers.count == 0 ? .gray : .red)
                            }
                            .overlay {
                                if viewModel.declineLoading {
                                    ProgressView()
                                        .tint(.white)
                                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                                        .background {
                                            RoundedRectangle(cornerRadius: 15)
                                                .foregroundStyle(.red)
                                        }
                                }
                            }
                    }
                    Button {
                        viewModel.acceptOffer(at: selectedOffer)
                    } label: {
                        Label("Accept", systemImage: "checkmark")
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 30)
                            .background {
                                RoundedRectangle(cornerRadius: 15)
                                    .foregroundStyle(viewModel.offers.count == 0 ? .gray : .green)
                            }
                            .overlay {
                                if viewModel.acceptLoading {
                                    ProgressView()
                                        .tint(.white)
                                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                                        .background {
                                            RoundedRectangle(cornerRadius: 15)
                                                .foregroundStyle(.green)
                                        }
                                }
                            }
                    }
                }
                .disabled(viewModel.offers.count == 0 || viewModel.declineLoading || viewModel.acceptLoading)
            } else {
                Label("Declined", systemImage: "xmark")
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 30)
                    .background {
                        RoundedRectangle(cornerRadius: 15)
                            .foregroundStyle(.gray)
                    }
            }
        }
        .onAppear {
            setupAppearance()
            self.viewModel.offers = self.offers
            self.viewModel.loadUserDatas()
        }
        .onChange(of: self.offers) {
            self.viewModel.offers = self.offers
            self.viewModel.loadUserDatas()
        }
        .sheet(isPresented: $viewModel.openBrowser) {
            BrowserView(url: viewModel.browserURL)
                .ignoresSafeArea()
        }
        
    }
    
    private func setupAppearance() {
        UIPageControl.appearance().currentPageIndicatorTintColor = .accent
        UIPageControl.appearance().pageIndicatorTintColor = UIColor.gray.withAlphaComponent(0.5)
    }
}

struct OfferView: View {
    var shift: Shift
    var offer: Offer
    var userData: UserData
    
    var body: some View {
        VStack {
            HStack(spacing: 5) {
                Text("\(userData.firstName) \(userData.lastName)")
                    .fontWeight(.bold)
                Text("will work for you on:")
            }
            .padding(.bottom, 10)
            .foregroundStyle(offer.status == .declined ? Color.secondary : .accent)
            
            Text("\(shift.start, formatter: dateFormatter)")
                .font(.callout)
                .foregroundStyle(.secondary)
            Text(shift.location)
                .fontWeight(.semibold)
                .foregroundStyle(offer.status == .declined ? Color.secondary : .black)
            Text("\(shift.start, formatter: timeFormatter) - \(shift.end, formatter: timeFormatter)")
                .foregroundStyle(.secondary)
                .fontWeight(.semibold)
            
            if shift.compensation.type != .give {
                Image(systemName: "arrow.up.arrow.down")
                    .font(.title2)
                    .foregroundStyle(offer.status == .declined ? Color.secondary : .accent)
                    .fontWeight(.semibold)
                    .padding(.vertical, 10)
            }
            
            if shift.compensation.type == .trade {
                Group {
                    HStack(spacing: 4) {
                        Text("If you work for ") +
                        Text(offer.id ?? "").fontWeight(.bold)
                    }
                    Text(" on one of these dates:")
                        .padding(.bottom, 10)
                }
                .foregroundStyle(offer.status == .declined ? Color.secondary : .accent)
                
                ScrollView {
                    if let availabilities = shift.compensation.availabilities {
                        ForEach(availabilities, id: \.self) { availability in
                            Text("\(availability.date, formatter: dateFormatter) from \(availability.startTime, formatter: timeFormatter) to \(availability.endTime, formatter: timeFormatter)")
                                .font(.headline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .frame(maxHeight: 50)
                
            } else if shift.compensation.type == .sell {
                Text("If you pay him/her:")
                    .foregroundStyle(offer.status == .declined ? Color.secondary : .accent)
                    .padding(.bottom, 5)
                Text("\(Int(shift.compensation.amount ?? 0))$")
                    .fontWeight(.bold)
                    .font(.title)
                    .fontDesign(.rounded)
                    .foregroundStyle(offer.status == .declined ? Color.secondary : .black)
                HStack(spacing: 3) {
                    Text("Transfered via")
                    Text("interac")
                        .italic()
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
        }
        .padding(.bottom, 40)
        .disabled(offer.status == .declined)
    }
}


struct ReviewPickupModalView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper()
    }
    
    struct PreviewWrapper: View {
        private var shift = Shift()
        @State private var offers: [Offer]
        @State var detentHeight: CGFloat = 0
        @State var shouldReload: Bool = false
        
        init() {
            var tempShift = Shift()
            tempShift.compensation.type = .sell
            
            var offer1 = Offer(shiftId: "efvwasv")
            offer1.from = "FvdkgyDxm5X5akm9thNZOYLcW5E2"
            
            var offer2 = Offer(shiftId: "sdfvsva")
            offer2.from = "FvdkgyDxm5X5akm9thNZOYLcW5E2"
            offer2.status = .declined
            
            self.shift = tempShift
            self.offers = [offer1, offer2]
        }
        
        var body: some View {
            Text("Bruv")
                .sheet(isPresented: .constant(true)) {
                    ReviewRequestModalView(shouldReloadRequests: $shouldReload, shift: shift, offers: $offers)
                        .readHeight()
                        .onPreferenceChange(HeightPreferenceKey.self, perform: { height in
                            if let height {
                                self.detentHeight = height
                            }
                        })
                        .presentationDetents([.height(self.detentHeight)])
                }
                .onDisappear {
                    if shouldReload {
                        print("Reloading data")
                    }
                }
        }
    }
}
