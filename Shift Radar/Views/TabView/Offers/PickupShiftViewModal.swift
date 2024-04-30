//
//  PickupShiftViewModal.swift
//  Shift Radar
//
//  Created by Justin Lefrançois on 2023-12-23.
//

import SwiftUI

struct PickupShiftModalView: View {
    @EnvironmentObject var appModel: AppViewModel
    @Environment(\.dismiss) var dismiss
    var model = PickupShiftModalViewModel()
    
    var shift: Shift
    var actionCancel: (() -> Void)?
    
    @State var showAlert: Bool = false
    @State var isLoading: Bool = false
    @State var resetSwipe: Bool = false
    
    var body: some View {
        NavigationView {
            VStack {
                Text("You will be working on:")
                    .foregroundStyle(.accent)
                    .padding(.bottom, 5)
                
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
                
                switch shift.compensation.type {
                case .give:
                    EmptyView()
                case .sell:
                    Text("In exchange of:")
                        .foregroundStyle(.accent)
                        .padding(.bottom, 5)
                    Text("\(Int(shift.compensation.amount ?? 0))$")
                        .font(.title)
                        .fontWeight(.bold)
                        .fontDesign(.rounded)
                    HStack(spacing: 3) {
                        Text("Transfered via")
                        Text("interac")
                            .italic()
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                case .trade:
                    Text("In exchange of one of these:")
                        .foregroundStyle(.accent)
                        .padding(.bottom, 5)
                    ScrollView {
                        VStack {
                            if let availabilities = shift.compensation.availabilities {
                                ForEach(availabilities, id: \.self) { availability in
                                    Text("\(availability.date, formatter: dateFormatter) from \(availability.startTime, formatter: timeFormatter) to \(availability.endTime, formatter: timeFormatter)")
                                        .font(.headline)
                                        .foregroundStyle(.secondary)
                                }
                            } else {
                                Text("Nothing to offer.")
                            }
                        }
                    }
                }
                
                Spacer()
                
                if shift.createdBy != appModel.uid {
                    SwipeToConfirmButton(alternateText: "Swipe to accept")
                        .onSwipeSuccess {
                            self.model.pickupShift(shiftId: shift.id, userData: appModel.userData) { result in
                                switch result {
                                case .success( _):
                                    dismiss()
                                case .failure( _):
                                    self.showAlert = true
                                }
                            }
                        }
                        .resetState($resetSwipe)
                } else {
                    HStack(spacing: 15) {
                        Button {
                            isLoading = true
                            self.model.deleteShift(shift) { result in
                                switch result {
                                case .success( _):
                                    isLoading = false
                                    dismiss()
                                case .failure( _):
                                    isLoading = false
                                    self.showAlert = true
                                }
                            }
                        } label: {
                            Label("Remove", systemImage: "trash")
                                .fontWeight(.semibold)
                                .foregroundStyle(.white)
                                .padding(.vertical, 12)
                                .padding(.horizontal, 30)
                                .frame(maxWidth: .infinity)
                                .background {
                                    RoundedRectangle(cornerRadius: 15)
                                        .foregroundStyle(isLoading ? .gray : .red)
                                }
                                .overlay {
                                    if isLoading {
                                        ProgressView()
                                    }
                                }
                                .disabled(isLoading)
                        }
                        Button {
                            
                        } label: {
                            Label("Edit", systemImage: "pencil")
                                .fontWeight(.semibold)
                                .foregroundStyle(.white)
                                .padding(.vertical, 12)
                                .padding(.horizontal, 30)
                                .frame(maxWidth: .infinity)
                                .background {
                                    RoundedRectangle(cornerRadius: 15)
                                        .foregroundStyle(.blue)
                                }
                                .disabled(isLoading)
                        }
                    }
                }
            }
            .navigationTitle(
                Text("SHIFT DETAILS")
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
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text(self.model.error?.title ?? "Error"),
                    message: Text(self.model.error?.message ?? "Unknown error"),
                    dismissButton: .default(Text("Ok")) {
                        self.resetSwipe.toggle()
                    })
            }
            .padding()
        }
    }
}

struct PickupShiftModalView_Previews: PreviewProvider {
    
    static var previews: some View {
        Text("Bruv")
            .sheet(isPresented: .constant(true), content: {
                PickupShiftModalView(shift: Shift())
                    .presentationDetents([.fraction(0.35)])
            })
            .environmentObject(AppViewModel())
    }
}
