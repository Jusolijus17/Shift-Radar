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
    
    @StateObject var model: OfferShiftModalViewModel
    
    @State private var success: Bool = false
    @State private var showError: Bool = false
    
    init(shift: Shift, isEditing: Bool) {
        _model = StateObject(wrappedValue: OfferShiftModalViewModel(shift: shift, isEditing: isEditing))
    }
    
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
                        .onChange(of: model.shiftErrorType, { _, newValue in
                            if newValue == .saving {
                                self.showError = true
                            }
                        })
                        .alert(isPresented: $showError) {
                            Alert(
                                title: Text("Error saving shift"),
                                message: Text("Please try again."),
                                dismissButton: .default(Text("Ok")) {
                                    self.viewModel.confirmOffer = false
                                    self.dismiss()
                                })
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
    @EnvironmentObject var model: OfferShiftModalViewModel
    @Environment(\.dismiss) var dismiss
    
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
                            DatePicker("", selection: $model.shift.start, displayedComponents: .date)
                                .labelsHidden()
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.bottom)
                        
                        HStack(alignment: .bottom) {
                            VStack(alignment: .leading) {
                                Text("START TIME")
                                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                                DatePicker("", selection: $model.shift.start, displayedComponents: .hourAndMinute)
                                    .labelsHidden()
                                    .tint(.accent)
                                    .onChange(of: model.shift.start) { oldValue, newValue in
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
                                DatePicker("", selection: $model.shift.end, displayedComponents: .hourAndMinute)
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
                        
                        FilterSelector(filters: $model.positionFilters) { filter in
                            model.selectedPositionFilter = filter
                        }
                        .padding(.bottom, 10)
                        
                        FilterSelector(filters: $model.locationFilters) { filter in
                            model.selectedLocationFilter = filter
                        }
                        .padding(.bottom, 10)
                        
                        PositionSelector(positionFilter: $model.selectedPositionFilter, locationFilter: $model.selectedLocationFilter, selection: $model.shift.location)
                        
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
                    .onChange(of: model.shift.compensation.type) { _, _ in
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            withAnimation {
                                reader.scrollTo("bottom")
                            }
                        }
                    }
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            withAnimation {
                                reader.scrollTo("bottom")
                            }
                        }
                    }
                }
            }
            
            Button {
                vibrate.toggle()
                if model.isEditing {
                    model.editShift {
                        Task {
                            await viewModel.refreshShifts()
                        }
                        dismiss()
                    }
                } else {
                    if model.shiftIsValid() {
                        withAnimation {
                            viewModel.confirmOffer = true
                        }
                    }
                }
            } label: {
                Group {
                    if model.isEditing {
                        Text("Save changes")
                    } else {
                        Label("Offer shift", systemImage: "plus")
                    }
                }
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
    @EnvironmentObject var model: OfferShiftModalViewModel
    @State private var sliderValue: Double = 0
    
    var body: some View {
        VStack {
            HStack {
                VStack {
                    Button {
                        model.changeCompensationType(newValue: .give)
                    } label: {
                        Image(systemName: "gift")
                            .foregroundStyle(model.shift.compensation.type == .give ? .white : .black.opacity(0.5))
                            .font(.title2)
                            .padding()
                            .background {
                                Circle()
                            }
                        
                    }
                    .foregroundStyle(model.shift.compensation.type == .give ? Color.accent : Color(uiColor: .tertiaryLabel))
                    Text("Give")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                }
                Spacer()
                VStack {
                    Button {
                        model.changeCompensationType(newValue: .sell)
                    } label: {
                        Image(systemName: "dollarsign")
                            .foregroundStyle(model.shift.compensation.type == .sell ? .white : .black.opacity(0.5))
                            .font(.title2)
                            .padding()
                            .background {
                                Circle()
                            }
                        
                    }
                    .foregroundStyle(model.shift.compensation.type == .sell ? Color.accent : Color(uiColor: .tertiaryLabel))
                    Text("Sell")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                }
                Spacer()
                VStack {
                    Button {
                        model.changeCompensationType(newValue: .trade)
                    } label: {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .foregroundStyle(model.shift.compensation.type == .trade ? .white : .black.opacity(0.5))
                            .font(.title2)
                            .padding()
                            .background {
                                Circle()
                            }
                        
                    }
                    .foregroundStyle(model.shift.compensation.type == .trade ? Color.accent : Color(uiColor: .tertiaryLabel))
                    Text("Trade")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                }
            }
            .sensoryFeedback(.impact, trigger: model.shift.compensation.type)
            
            switch model.shift.compensation.type {
            case .give:
                EmptyView()
            case .sell:
                HStack(alignment: .bottom) {
                    Text("0$")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                    CustomSlider(value: $sliderValue, range: 0...100, step: 5)
                        .onChange(of: sliderValue, { _, newValue in
                            model.shift.compensation.amount = newValue
                        })
                        .onAppear(perform: {
                            self.sliderValue = model.shift.compensation.amount ?? 0
                        })
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
    @EnvironmentObject var model: OfferShiftModalViewModel
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
                    model.shift.compensation.availabilities!.append(newSlot)
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            ScrollView {
                VStack {
                    if let availabilities = model.shift.compensation.availabilities {
                        ForEach(availabilities.indices, id: \.self) { index in
                            let availability = availabilities[index]
                            Text("Slot \(index + 1): \(availability.date, formatter: dateFormatter) from \(availability.startTime, formatter: timeFormatter) to \(availability.endTime, formatter: timeFormatter)")
                                .font(.system(size: 12, design: .rounded))
                                .foregroundStyle(.secondary)
                        }
                        .onDelete(perform: deleteAvailability)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
    
    func deleteAvailability(at offsets: IndexSet) {
        model.shift.compensation.availabilities!.remove(atOffsets: offsets)
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
                
                Text(shift.start, formatter: dateFormatter)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Text(shift.location)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                
                Text("\(shift.start, formatter: timeFormatter) - \(shift.end, formatter: timeFormatter)")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(.secondary)
                
                Image(systemName: "arrow.up.arrow.down")
                    .font(.title)
                    .fontWeight(.semibold)
                    .padding(.vertical)
                    .foregroundStyle(.accent)
                
                switch shift.compensation.type {
                case .give:
                    Text("Giving.")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                case .sell:
                    Text("Selling for:")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .padding(.bottom, 5)
                    Text("\(Int(shift.compensation.amount ?? 0))$")
                case .trade:
                    Text("In exchange of one of these dates:")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .padding(.bottom, 5)
                    ScrollView {
                        if let availabilities = shift.compensation.availabilities {
                            ForEach(availabilities, id: \.self) { availability in
                                Text("\(availability.date, formatter: dateFormatter) from \(availability.startTime, formatter: timeFormatter) to \(availability.endTime, formatter: timeFormatter)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
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
//                    shift.availabilities = [Availability(date: Date(), start: Date(), end: Date()), Availability(date: Date(), start: Date(), end: Date())]
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

