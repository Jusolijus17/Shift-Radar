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
    
    @StateObject var model: OfferShiftModel = OfferShiftModel()
    
    @State private var success: Bool = false
    
    var body: some View {
        Group {
            if !viewModel.confirmOffer {
                NavigationView {
                    ShiftDetailView()
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
                .transition(.move(edge: .leading))
            } else {
                NavigationView {
                    ConfirmShiftView(shift: $model.shift)
                        .onConfirm {
                            model.saveShift {
                                success.toggle()
                                viewModel.confirmOffer = false
                                dismiss()
                            }
                        }
                        .onCancel {
                            withAnimation {
                                viewModel.confirmOffer = false
                            }
                        }
                        .sensoryFeedback(.success, trigger: success)
                }
                .transition(.move(edge: .trailing))
            }
        }
        .environmentObject(model)
    }
}

struct ShiftDetailView: View {
    @EnvironmentObject var viewModel: OfferShiftViewModel
    @EnvironmentObject var model: OfferShiftModel
    
    @State private var vibrate: Bool = false
    
    init() {
        UIDatePicker.appearance().minuteInterval = 5
    }
    
    var body: some View {
        VStack {
            ScrollView {
                ScrollViewReader { reader in
                    VStack(alignment: .leading) {
                        VStack(alignment: .leading) {
                            Text("SELECT DATE")
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundStyle(model.shiftErrorType == .date ? Color.red : Color.black)
                            DatePicker("", selection: $model.shift.startTime, displayedComponents: .date)
                                .labelsHidden()
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.bottom)
                        
                        HStack(alignment: .bottom) {
                            VStack(alignment: .leading) {
                                Text("START TIME")
                                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                                DatePicker("", selection: $model.shift.startTime, displayedComponents: .hourAndMinute)
                                    .labelsHidden()
                                    .tint(.accent)
                                    .onChange(of: model.shift.startTime) { oldValue, newValue in
                                        model.refreshEndTime(oldValue, newValue)
                                    }
                            }
                            Text("TO")
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 5)
                                .padding(.bottom, 10)
                            VStack(alignment: .leading) {
                                Text("END TIME")
                                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                                DatePicker("", selection: $model.shift.endTime, displayedComponents: .hourAndMinute)
                                    .labelsHidden()
                                    .tint(.accent)
                            }
                            VStack(alignment: .leading) {
                                Text("\(model.hoursBetweenShiftTimes())H")
                                    .font(.system(size: 22, weight: .semibold, design: .rounded))
                                    .foregroundStyle(model.shiftErrorType == .duration ? Color.red : Color.black)
                                Text("SHIFT TIME")
                                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                                    .foregroundStyle(.secondary)
                            }
                        }
                        Text("LOCATION")
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundStyle(model.shiftErrorType == .location ? Color.red : Color.black)
                            .padding(.vertical, 5)
                        HStack {
                            Text("Filter:")
                                .font(.system(size: 10, weight: .semibold, design: .rounded))
                                .foregroundStyle(.secondary)
                            BoxSelector(options: model.filters, selectedOption: model.optionFilter)
                                .onSelectionChanged { selection in
                                    model.applyOptionFilter(selection)
                                }
                        }
                        .padding(.bottom, 10)
                        HStack {
                            Text("Recently used:")
                                .font(.system(size: 10, weight: .semibold, design: .rounded))
                                .foregroundStyle(.secondary)
                            ScrollView(.horizontal) {
                                BoxSelector(options: ["DOMESTIC", "TRANSBORDER", "INTERNATIONAL", "OTHER"])
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
                        Picker("", selection: $model.shift.location) {
                            ForEach(model.filteredMenuOptions, id: \.self) {
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
                            .id("bottom")
                    }
                    .sensoryFeedback(.success, trigger: vibrate)
                    .padding(.horizontal, 20)
                    .onChange(of: model.shift.compensationType) { _, _ in
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            withAnimation {
                                reader.scrollTo("bottom")
                            }
                        }
                    }
                }
            }
            
            Button {
                vibrate.toggle()
                if model.shiftIsValid() {
                    withAnimation {
                        viewModel.confirmOffer = true
                    }
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
                        if model.isSaving {
                            ProgressView()
                                .tint(.accentColor2)
                        }
                    }
                    .disabled(model.isSaving)
                    .padding(.horizontal)
            }
        }
    }
}

struct CompensationView: View {
    @EnvironmentObject var model: OfferShiftModel
    
    var body: some View {
        VStack {
            HStack {
                VStack {
                    Button {
                        model.changeCompensationType(newValue: .give)
                    } label: {
                        Image(systemName: "gift")
                            .foregroundStyle(model.shift.compensationType == .give ? .white : .black.opacity(0.5))
                            .font(.title2)
                            .padding()
                            .background {
                                Circle()
                            }
                        
                    }
                    .foregroundStyle(model.shift.compensationType == .give ? Color.accent : Color(uiColor: .tertiaryLabel))
                    Text("Give")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                }
                Spacer()
                VStack {
                    Button {
                        model.changeCompensationType(newValue: .sell)
                    } label: {
                        Image(systemName: "dollarsign")
                            .foregroundStyle(model.shift.compensationType == .sell ? .white : .black.opacity(0.5))
                            .font(.title2)
                            .padding()
                            .background {
                                Circle()
                            }
                        
                    }
                    .foregroundStyle(model.shift.compensationType == .sell ? Color.accent : Color(uiColor: .tertiaryLabel))
                    Text("Sell")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                }
                Spacer()
                VStack {
                    Button {
                        model.changeCompensationType(newValue: .trade)
                    } label: {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .foregroundStyle(model.shift.compensationType == .trade ? .white : .black.opacity(0.5))
                            .font(.title2)
                            .padding()
                            .background {
                                Circle()
                            }
                        
                    }
                    .foregroundStyle(model.shift.compensationType == .trade ? Color.accent : Color(uiColor: .tertiaryLabel))
                    Text("Trade")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                }
            }
            .sensoryFeedback(.impact, trigger: model.shift.compensationType)
            
            switch model.shift.compensationType {
            case .give:
                EmptyView()
            case .sell:
                HStack(alignment: .bottom) {
                    Text("0$")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                    CustomSlider(value: $model.shift.moneyCompensation, range: 0...100, step: 5)
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
    @EnvironmentObject var model: OfferShiftModel
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
                
                DatePicker("", selection: $newAvailabilityEndTime,
                           displayedComponents: .hourAndMinute)
                .labelsHidden()
                
                Button(action: {
                    let newSlot = Availability(date: newAvailabilityDate,
                                               startTime: newAvailabilityStartTime,
                                               endTime: newAvailabilityEndTime)
                    model.shift.availabilities.append(newSlot)
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            ScrollView {
                VStack {
                    ForEach(model.shift.availabilities.indices, id: \.self) { index in
                        let availability = model.shift.availabilities[index]
                        Text("Slot \(index + 1): \(availability.date, formatter: dateFormatter) from \(availability.startTime, formatter: timeFormatter) to \(availability.endTime, formatter: timeFormatter)")
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
        model.shift.availabilities.remove(atOffsets: offsets)
    }
}

struct ConfirmShiftView: View {
    
    @Binding var shift: Shift
    
    var actionConfirm: (() -> Void)?
    var actionCancel: (() -> Void)?
    
    var body: some View {
        NavigationView {
            VStack {
                Text("YOU'RE OFFERING:")
                    .underline()
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                
                Spacer()
                
                Text(shift.startTime, formatter: dateFormatter)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Text(shift.location)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                
                Text("\(shift.startTime, formatter: timeFormatter) - \(shift.endTime, formatter: timeFormatter)")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(.secondary)
                
                Image(systemName: "arrow.up.arrow.down")
                    .font(.title)
                    .fontWeight(.semibold)
                    .padding(.vertical)
                    .foregroundStyle(.accent)
                
                switch shift.compensationType {
                case .give:
                    Text("Simply giving.")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                case .sell:
                    Text("Selling for:")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .padding(.bottom, 5)
                    Text("\(Int(shift.moneyCompensation))$")
                case .trade:
                    Text("In exchange of one of these dates:")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .padding(.bottom, 5)
                    ScrollView {
                        ForEach(shift.availabilities, id: \.self) { availability in
                            Text("\(availability.date, formatter: dateFormatter) from \(availability.startTime, formatter: timeFormatter) to \(availability.endTime, formatter: timeFormatter)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .frame(maxHeight: 50)
                }
                
                Spacer()
                
                SwipeToConfirmButton()
                    .onSwipeSuccess {
                        if let actionConfirm = actionConfirm {
                            actionConfirm()
                        }
                    }
            }
            .toolbar {
                ToolbarItem {
                    Button {
                        if let actionCancel = actionCancel {
                            actionCancel()
                        }
                    } label: {
                        Image(systemName: "arrow.backward.circle.fill")
                            .font(.title2)
                    }
                    .tint(.secondary.opacity(0.5))
                }
            }
        }
    }
}

extension ConfirmShiftView {
    func onConfirm(_ action : @escaping () -> Void) -> Self {
        var this = self
        this.actionConfirm = action
        return this
    }
    
    func onCancel(_ action : @escaping () -> Void) -> Self {
        var this = self
        this.actionCancel = action
        return this
    }
}

//#Preview {
//    Text("Bruv")
//        .sheet(isPresented: .constant(true), content: {
//            ConfirmShiftView(shift: .constant(Shift()))
//                .presentationDetents([.medium])
//
//        })
//}

//struct ConfirmShiftView_Previews: PreviewProvider {
//    struct PreviewWrapper: View {
//        @State var shift = Shift()
//
//        var body: some View {
//            Text("Bruv")
//                .sheet(isPresented: .constant(true), content: {
//                    ConfirmShiftView(shift: $shift)
//                        .presentationDetents([.fraction(0.5)])
//                })
//                .onAppear {
//                    shift.location = "TESTING"
//                    shift.compensationType = .trade
//                    shift.availabilities = [Availability(date: Date(), startTime: Date(), endTime: Date()), Availability(date: Date(), startTime: Date(), endTime: Date())]
//                }
//        }
//    }
//
//    static var previews: some View {
//        PreviewWrapper()
//    }
//}


#Preview {
    TabViewManager_Previews.PreviewWrapper(selectedTab: 0)
}

