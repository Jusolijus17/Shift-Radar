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
    var shift: Shift
    @Binding var offers: [Offer]
    
    init(shift: Shift, offers: Binding<[Offer]>) {
        self.shift = shift
        self._offers = offers
        setupAppearance()
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if offers.count != 0 {
                    TabView {
                        ForEach(offers) { offer in
                            OfferView(offer: offer, shift: shift)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .automatic))
                    .padding(.top, 10)
                } else {
                    Spacer()
                    ProgressView()
                        .scaleEffect(1.5)
                }
                
                Spacer()
                
                HStack(spacing: 15) {
                    Button {
                        
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
            .navigationTitle(
                Text("OFFER DETAILS")
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                    }
                    .tint(.secondary.opacity(0.5))
                }
            }
        }
    }
    
    func setupAppearance() {
        UIPageControl.appearance().currentPageIndicatorTintColor = .accent
        UIPageControl.appearance().pageIndicatorTintColor = UIColor.gray.withAlphaComponent(0.5)
    }
}

struct OfferView: View {
    var offer: Offer
    var shift: Shift
    
    var body: some View {
        VStack {
            HStack(spacing: 5) {
                Text("\(offer.firstName) \(offer.lastName)")
                    .fontWeight(.bold)
                Text("will work for you on:")
            }
            .padding(.bottom, 10)
            .foregroundStyle(.accent)
            
            Text("\(shift.start, formatter: dateFormatter)")
                .font(.callout)
                .foregroundStyle(.secondary)
            Text(shift.location!)
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
                        Text(offer.firstName).fontWeight(.bold)
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
            
            Spacer()
        }
    }
}

struct ReviewPickupModalView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper()
    }
    
    struct PreviewWrapper: View {
        private var shift = Shift()
        @State private var offers: [Offer] = [Offer(firstName: "Justin", lastName: "Lefrançois", shiftId: "efvwasv"), Offer(firstName: "Camilo", lastName: "Rossi", shiftId: "sdfvsva")]
        
        init() {
            self.shift.compensation.type = .sell
        }
        
        var body: some View {
            Text("Bruv")
                .sheet(isPresented: .constant(true), content: {
                    ReviewPickupModalView(shift: shift, offers: $offers)
                        .presentationDetents([.medium])
                })
        }
    }
}
