//
//  OfferShiftViewModal.swift
//  Shift Radar
//
//  Created by Justin Lefrançois on 2023-11-06.
//

import SwiftUI

struct OfferShiftModalView: View {
    @EnvironmentObject var viewModel: OfferShiftViewModel
    @Environment(\.dismiss) var dismiss
    
    init() {
        UIDatePicker.appearance().minuteInterval = 5
    }
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                VStack(alignment: .leading) {
                    Text("SELECT DATE")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                    DatePicker("", selection: $viewModel.shiftData.date, displayedComponents: .date)
                        .labelsHidden()
                }
                .padding(.bottom)
                
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading) {
                        Text("START TIME")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                        DatePicker("", selection: $viewModel.shiftData.startTime, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                            .tint(.accent)
                    }
                    Text("TO")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 5)
                        .padding(.bottom, 10)
                    VStack(alignment: .leading) {
                        Text("END TIME")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                        DatePicker("", selection: $viewModel.shiftData.endTime, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                            .tint(.accent)
                    }
                    VStack(alignment: .leading) {
                        Text("\(viewModel.hoursBetweenShiftTimes())H")
                            .font(.system(size: 22, weight: .semibold, design: .rounded))
                        Text("SHIFT TIME")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundStyle(.secondary)
                    }
                }
                Text("LOCATION")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .padding(.vertical, 5)
                HStack {
                    Text("Recently used:")
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .foregroundStyle(.secondary)
                    BoxSelector(options: ["RAMP", "FLOATER", "BAGROOM"]) { selection in
                        // Do something after tapping
                    }
                }
                .padding(.bottom, 10)
                HStack {
                    Text("Filter:")
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .foregroundStyle(.secondary)
                    ScrollView(.horizontal) {
                        BoxSelector(options: ["DOMESTIC", "TRANSBORDER", "INTERNATIONAL", "OTHER"]) { selection in
                            // Do something after tapping
                        }
                    }
                    .scrollIndicators(.hidden)
                    .background(
                        GeometryReader { geometry in
                            HStack {
                                Spacer()
                                // Ombre à droite
                                LinearGradient(gradient: Gradient(colors: [Color.clear, Color.black.opacity(0.1)]), startPoint: .leading, endPoint: .trailing)
                                    .frame(width: 10)
                                    .blur(radius: 3)
                            }
                            .frame(width: geometry.size.width, height: geometry.size.height)
                        }
                            .clipped()
                    )
                    .edgesIgnoringSafeArea(.horizontal)
                }
                .padding(.bottom, 10)
                Picker("", selection: $viewModel.shiftData.location) {
                    ForEach(viewModel.menuOptions, id: \.self) {
                        Text($0)
                    }
                }
                .pickerStyle(.menu)
                .frame(height: 50)
                .frame(maxWidth: .infinity, alignment: .leading)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color.accentColor.opacity(0.5), lineWidth: 1)
                )
                Text("COMPENSATION")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .padding(.vertical, 5)
                Text("What do I want in return for my shift?")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(.secondary)
                CompensationView()
                Spacer()
                Button {
                    viewModel.saveShift {
                        dismiss()
                    }
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
                        .overlay {
                            if viewModel.isSaving {
                                ProgressView()
                                    .tint(.accentColor2)
                            }
                        }
                        .disabled(viewModel.isSaving)
                }
            }
            .padding(.horizontal, 20)
            .navigationTitle("Offer shift")
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
}

struct CompensationView: View {
    @EnvironmentObject var viewModel: OfferShiftViewModel
    
    var body: some View {
        VStack {
            HStack {
                VStack {
                    Button {
                        viewModel.changeCompensationType(newValue: .give)
                    } label: {
                        Image(systemName: "gift")
                            .foregroundStyle(viewModel.shiftData.compensationType == .give ? .white : .black.opacity(0.5))
                            .font(.title2)
                            .padding()
                            .background {
                                Circle()
                            }
                        
                    }
                    .foregroundStyle(viewModel.shiftData.compensationType == .give ? Color.accent : Color(uiColor: .tertiaryLabel))
                    Text("Give")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                }
                Spacer()
                VStack {
                    Button {
                        viewModel.changeCompensationType(newValue: .sell)
                    } label: {
                        Image(systemName: "dollarsign")
                            .foregroundStyle(viewModel.shiftData.compensationType == .sell ? .white : .black.opacity(0.5))
                            .font(.title2)
                            .padding()
                            .background {
                                Circle()
                            }
                        
                    }
                    .foregroundStyle(viewModel.shiftData.compensationType == .sell ? Color.accent : Color(uiColor: .tertiaryLabel))
                    Text("Sell")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                }
                Spacer()
                VStack {
                    Button {
                        viewModel.changeCompensationType(newValue: .trade)
                    } label: {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .foregroundStyle(viewModel.shiftData.compensationType == .trade ? .white : .black.opacity(0.5))
                            .font(.title2)
                            .padding()
                            .background {
                                Circle()
                            }
                        
                    }
                    .foregroundStyle(viewModel.shiftData.compensationType == .trade ? Color.accent : Color(uiColor: .tertiaryLabel))
                    Text("Trade")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                }
            }
            .sensoryFeedback(.impact, trigger: viewModel.shiftData.compensationType)
            
            switch viewModel.shiftData.compensationType {
            case .give:
                Text("Give")
                    .padding(.vertical, 5)
            case .sell:
                HStack(alignment: .bottom) {
                    Text("0$")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                    CustomSlider(value: $viewModel.shiftData.moneyCompensation, range: 0...100, step: 5)
                        .padding(.bottom, 10)
                    Text("100$")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                }
                .padding(.vertical)
            case .trade:
                AvailabilitiesView()
            }
        }
    }
}

struct AvailabilitiesView: View {
    @EnvironmentObject var viewModel: OfferShiftViewModel
    @State private var newAvailabilityDate = Date()
    @State private var newAvailabilityStartTime = Date()
    @State private var newAvailabilityEndTime = Date()
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("AVAILABILITIES")
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .padding(.vertical, 5)
            HStack {
                DatePicker("",
                           selection: $newAvailabilityDate,
                           displayedComponents: .date)
                .labelsHidden()
                
                DatePicker("", selection: $newAvailabilityStartTime,
                           displayedComponents: .hourAndMinute)
                .labelsHidden()
                
                Text("TO")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 2)
                
                DatePicker("", selection: $newAvailabilityEndTime,
                           displayedComponents: .hourAndMinute)
                .labelsHidden()
                
                Button(action: {
                    let newSlot = Availability(date: newAvailabilityDate,
                                               startTime: newAvailabilityStartTime,
                                               endTime: newAvailabilityEndTime)
                    viewModel.shiftData.availabilities.append(newSlot)
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            ScrollView {
                VStack {
                    ForEach(viewModel.shiftData.availabilities.indices, id: \.self) { index in
                        let availability = viewModel.shiftData.availabilities[index]
                        Text("Slot \(index + 1): \(availability.date, formatter: itemFormatter) from \(availability.startTime, formatter: timeFormatter) to \(availability.endTime, formatter: timeFormatter)")
                            .font(.system(size: 12, design: .rounded))
                            .foregroundStyle(.secondary)
                    }
                    .onDelete(perform: deleteAvailability)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
    
    func deleteAvailability(at offsets: IndexSet) {
        viewModel.shiftData.availabilities.remove(atOffsets: offsets)
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .none
    return formatter
}()

private let timeFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .none
    formatter.timeStyle = .short
    return formatter
}()
