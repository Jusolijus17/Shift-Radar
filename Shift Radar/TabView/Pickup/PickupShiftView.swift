//
//  HomePage.swift
//  Shift Radar
//
//  Created by Justin Lefrançois on 2023-10-24.
//

import SwiftUI

struct PickupShiftView: View {
    @StateObject var viewModel = PickupShiftViewModel()
    
    @State private var selectedShift: Shift?
    @State private var selectedDetent: PresentationDetent = .medium
    
    var body: some View {
        NavigationView {
            VStack {
                SearchView() { startDate, endDate in
                    viewModel.searchShifts(startDate: startDate, endDate: endDate)
                }
                .padding()
                
                HStack {
                    Text(getListTitle())
                        .font(.subheadline)
                    Spacer()
                    Button(action: {
                        
                    }, label: {
                        Image(systemName: "line.3.horizontal")
                            .font(.title2)
                            .foregroundStyle(.gray)
                    })
                    Button(action: {
                        
                    }, label: {
                        Image(systemName: "line.3.horizontal.decrease")
                            .font(.title2)
                            .foregroundStyle(.gray)
                    })
                }
                .padding(.horizontal)
                
                if !viewModel.offeredShifts.isEmpty || !viewModel.filteredShifts.isEmpty {
                    ScrollView {
                        VStack(spacing: 10) {
                            ForEach(viewModel.filteredShifts.isEmpty ? $viewModel.offeredShifts : $viewModel.filteredShifts) { $shift in
                                ShiftView(shift: $shift)
                                    .onTap {
                                        if $shift.wrappedValue.compensation.type == .give {
                                            selectedDetent = .fraction(0.35)
                                        } else {
                                            selectedDetent = .medium
                                        }
                                        selectedShift = $shift.wrappedValue
                                    }
                                    .padding(.horizontal)
                            }
                            Spacer()
                        }
                        .padding(.top, 15)
                        .sheet(item: $selectedShift) { shift in
                            PickupShiftModalView(shift: shift, actionCancel: {
                                selectedShift = nil
                            })
                            .presentationDetents([.fraction(0.35), .medium], selection: $selectedDetent)
                        }
                    }
                } else {
                    Spacer()
                    Image("desert")
                        .padding()
                    Text("No shifts offered right now")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .padding(.vertical, 5)
                        .foregroundStyle(Color.gray)
                    Text("You can still search for past shifts")
                        .font(.caption)
                        .foregroundStyle(Color.gray)
                    Spacer()
                }
            }
            .background(Color.background)
        }
    }
    
    private func getListTitle() -> String {
        let count = viewModel.filteredShifts.count
        let resultString = count == 1 ? "result" : "results"
        return "Available shifts" + (count > 0 ? " (\(count) \(resultString))" : "")
    }
}

struct DatePickerButtonView: View {
    @State private var isDatePickerShown = false
    @State private var selectedDate = Date()

    var body: some View {
        VStack {
            Button(action: {
                isDatePickerShown = true
            }) {
                HStack {
                    Image(systemName: "calendar")
                    Text("Select Dates")
                }
                .padding(.horizontal)
                .frame(maxWidth: .infinity, minHeight: 40, alignment: .leading)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                )
            }
            .padding(.horizontal)
            .sheet(isPresented: $isDatePickerShown) {
                VStack {
                    DatePicker("Select Date", selection: $selectedDate, displayedComponents: [.date])
                        .datePickerStyle(GraphicalDatePickerStyle())
                        .padding()
                    Button("Done") {
                        isDatePickerShown = false
                    }
                    .padding()
                }
            }
        }
    }
}

#Preview {
    TabViewManager_Previews.PreviewWrapper(selectedTab: 1)
}
