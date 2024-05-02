//
//  PickupShiftViewModal.swift
//  Shift Radar
//
//  Created by Justin Lefrançois on 2023-12-23.
//

import SwiftUI
import UIKit

struct ReviewPickupModalView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel = ReviewPickupModalViewModel()
    @State private var selectedOffer = 0
    
    @State var shift: Shift
    @Binding var offers: [Offer]
    
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
            
            if offers.count != 0 && !viewModel.userDatas.isEmpty {
                HeightPreservingTabView(selection: $selectedOffer) {
                    ForEach(offers.indices, id: \.self) { index in
                        let offer = offers[index]
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
            
            HStack(spacing: 15) {
                Button {
                    print("Selected offer: ", offers[selectedOffer])
                    viewModel.declineOffer(offer: offers[selectedOffer])
                } label: {
                    Label("Decline", systemImage: "xmark")
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 30)
                        .background {
                            RoundedRectangle(cornerRadius: 15)
                                .foregroundStyle(offers.count == 0 ? .gray : .red)
                        }
                }
                Button {
                    viewModel.acceptOffer(offer: offers[selectedOffer])
                } label: {
                    Label("Accept", systemImage: "checkmark")
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 30)
                        .background {
                            RoundedRectangle(cornerRadius: 15)
                                .foregroundStyle(offers.count == 0 ? .gray : .green)
                        }
                }
            }
            .disabled(offers.count == 0)
        }
        .onAppear {
            setupAppearance()
            self.viewModel.loadUserDatas(offers: offers)
        }
        .onChange(of: self.offers) {
            self.viewModel.loadUserDatas(offers: offers)
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
            .foregroundStyle(.accent)
            
            Text("\(shift.start, formatter: dateFormatter)")
                .font(.callout)
                .foregroundStyle(.secondary)
            Text(shift.location)
                .fontWeight(.semibold)
            Text("\(shift.start, formatter: timeFormatter) - \(shift.end, formatter: timeFormatter)")
                .foregroundStyle(.secondary)
                .fontWeight(.semibold)
            
            if shift.compensation.type != .give {
                Image(systemName: "arrow.up.arrow.down")
                    .font(.title2)
                    .foregroundStyle(.accent)
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
                .foregroundStyle(.accent)
                
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
                    .foregroundStyle(.accent)
                    .padding(.bottom, 5)
                Text("\(Int(shift.compensation.amount ?? 0))$")
                    .fontWeight(.bold)
                    .font(.title)
                    .fontDesign(.rounded)
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
        
        init() {
            var tempShift = Shift()
            tempShift.compensation.type = .sell
            
            var offer1 = Offer(shiftId: "efvwasv")
            offer1.from = "FvdkgyDxm5X5akm9thNZOYLcW5E2"
            
            var offer2 = Offer(shiftId: "sdfvsva")
            offer2.from = "FvdkgyDxm5X5akm9thNZOYLcW5E2"
            
            self.shift = tempShift
            self.offers = [offer1, offer2]
        }
        
        var body: some View {
            Text("Bruv")
                .sheet(isPresented: .constant(true)) {
                    ReviewPickupModalView(shift: shift, offers: $offers)
                        .readHeight()
                        .onPreferenceChange(HeightPreferenceKey.self, perform: { height in
                            if let height {
                                self.detentHeight = height
                            }
                        })
                        .presentationDetents([.height(self.detentHeight)])
                }
        }
    }
}
