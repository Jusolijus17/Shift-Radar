//
//  OfferShiftView.swift
//  Shift Radar
//
//  Created by Justin Lefrançois on 2023-10-24.
//

import SwiftUI

struct OfferShiftView: View {
    @StateObject private var viewModel = OfferShiftViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isEmpty {
                    NoOfferView(showModal: $viewModel.showModal)
                } else {
                    Text("Offers here...")
                }
            }
            .sheet(isPresented: $viewModel.showModal) {
                OfferShiftModalView()
            }
        }
        .environmentObject(viewModel)
    }
}

struct NoOfferView: View {
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

struct OfferShiftModalView: View {
    @EnvironmentObject var viewModel: OfferShiftViewModel
    @Environment(\.dismiss) var dismiss
    @State private var selectedItem: String = "Option 1"
    
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
                
                HStack {
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
                    ForEach(viewModel.locations, id: \.self) {
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

struct BoxSelector: View {
    let options: [String]
    @State private var selectedOption: String?
    
    var selectionChanged: (_ selection: String) -> Void
    
    var body: some View {
        HStack {
            ForEach(options, id: \.self) { option in
                Text(option)
                    .font(.system(size: 12, design: .rounded))
                    .padding(5)
                    .background {
                        RoundedRectangle(cornerRadius: 5)
                            .fill(selectedOption == option ? Color.accentColor : Color.clear)
                            .strokeBorder(style: StrokeStyle(lineWidth: selectedOption == option ? 0 : 1, dash: [4, 4]))
                    }
                    .foregroundColor(selectedOption == option ? Color.white : .secondary)
                    .onTapGesture {
                        withAnimation {
                            if selectedOption == option {
                                selectedOption = nil
                                selectionChanged(option)
                            } else {
                                selectedOption = option
                                selectionChanged(option)
                            }
                        }
                    }
                    .sensoryFeedback(.impact, trigger: selectedOption)
            }
        }
    }
}

enum CompensationType {
    case give
    case sell
    case trade
}

struct CompensationView: View {
    @State private var compensationType: CompensationType = .sell
    @EnvironmentObject var viewModel: OfferShiftViewModel
    
    var body: some View {
        VStack {
            HStack {
                VStack {
                    Button {
                        compensationType = .give
                    } label: {
                        Image(systemName: "gift")
                            .foregroundStyle(compensationType == .give ? .white : .black.opacity(0.5))
                            .font(.title2)
                            .padding()
                            .background {
                                Circle()
                            }
                        
                    }
                    .foregroundStyle(compensationType == .give ? Color.accent : Color(uiColor: .tertiaryLabel))
                    Text("Give")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                }
                Spacer()
                VStack {
                    Button {
                        compensationType = .sell
                    } label: {
                        Image(systemName: "dollarsign")
                            .foregroundStyle(compensationType == .sell ? .white : .black.opacity(0.5))
                            .font(.title2)
                            .padding()
                            .background {
                                Circle()
                            }
                        
                    }
                    .foregroundStyle(compensationType == .sell ? Color.accent : Color(uiColor: .tertiaryLabel))
                    Text("Sell")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                }
                Spacer()
                VStack {
                    Button {
                        compensationType = .trade
                    } label: {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .foregroundStyle(compensationType == .trade ? .white : .black.opacity(0.5))
                            .font(.title2)
                            .padding()
                            .background {
                                Circle()
                            }
                        
                    }
                    .foregroundStyle(compensationType == .trade ? Color.accent : Color(uiColor: .tertiaryLabel))
                    Text("Trade")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                }
            }
            .sensoryFeedback(.impact, trigger: compensationType)
            
            switch compensationType {
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
                ForEach(viewModel.shiftData.availabilities.indices, id: \.self) { index in
                    let availability = viewModel.shiftData.availabilities[index]
                    Text("Slot \(index + 1): \(availability.date, formatter: itemFormatter) from \(availability.startTime, formatter: timeFormatter) to \(availability.endTime, formatter: timeFormatter)")
                        .font(.system(size: 12, design: .rounded))
                        .foregroundStyle(.secondary)
                }
                .onDelete(perform: deleteAvailability)
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


struct CustomSlider: View {
    @Binding var value: Double
    var range: ClosedRange<Double>
    var step: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Slider(value: $value, in: range, step: step)
                    .padding(.vertical)
                Text("\(Int(value))$")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(.secondary)
                    .frame(width: 35, height: 20)
                    .offset(x: self.sliderOffset(sliderWidth: geometry.size.width), y: -30)
            }
        }
        .frame(height: 30)
    }
    
    private func sliderOffset(sliderWidth: CGFloat) -> CGFloat {
        let sliderRange = range.upperBound - range.lowerBound
        let sliderStep = CGFloat((value - range.lowerBound) / sliderRange)
        return sliderStep * (sliderWidth - 35) // 35 is the approximate width of the Text view
    }
}


#Preview {
    TabViewManager_Previews.PreviewWrapper(selectedTab: 1)
}
