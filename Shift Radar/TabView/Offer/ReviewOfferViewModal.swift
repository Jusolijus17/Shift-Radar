//
//  PickupShiftViewModal.swift
//  Shift Radar
//
//  Created by Justin Lefrançois on 2023-12-23.
//

import SwiftUI

struct ReviewPickupModalView: View {
    @Binding var shift: Shift
    var actionCancel: (() -> Void)?
    
    var body: some View {
        NavigationView {
            VStack {
                HStack(spacing: 5) {
                    Text("Alexandre Lafayette")
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
                            Text("Alexandre").fontWeight(.bold)
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
                    Text("If you pay him:")
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
                                    .foregroundStyle(.red)
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
                                    .foregroundStyle(.green)
                            }
                    }
                }
            }
            .navigationTitle(
                Text("OFFER DETAILS")
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem {
                    Button {
                        if let actionCancel = actionCancel {
                            actionCancel()
                        }
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                    }
                    .tint(.secondary.opacity(0.5))
                }
            }
            .padding()
        }
    }
}

struct ReviewPickupModalView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper()
    }
    
    struct PreviewWrapper: View {
        @State private var shift = Shift()
        
        var body: some View {
            Text("Bruv")
                .sheet(isPresented: .constant(true), content: {
                    ReviewPickupModalView(shift: $shift)
                        .presentationDetents([.medium])
                })
                .onAppear {
                    shift.compensation.type = .sell
                }
        }
    }
}
