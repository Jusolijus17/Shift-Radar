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
    
    @State private var success: Bool = false
    
    var body: some View {
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
                ConfirmShiftView()
                    .onConfirm {
                        viewModel.saveShift {
                            success.toggle()
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
}

struct ShiftDetailView: View {
    @EnvironmentObject var viewModel: OfferShiftViewModel
    
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
                            DatePicker("", selection: $viewModel.shiftData.startTime, displayedComponents: .date)
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
                                    .onChange(of: viewModel.shiftData.startTime) { oldValue, newValue in
                                        viewModel.refreshEndTime(oldValue, newValue)
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
                            BoxSelector(options: viewModel.filters)
                                .onSelectionChanged { selection in
                                    viewModel.applyOptionFilter(selection)
                                }
                        }
                        .padding(.bottom, 10)
                        HStack {
                            Text("Filter:")
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
                        Picker("", selection: $viewModel.shiftData.location) {
                            ForEach(viewModel.filteredMenuOptions, id: \.self) {
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
                    .onChange(of: viewModel.shiftData.compensationType) { _, newValue in
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
                withAnimation {
                    viewModel.confirmOffer = true
                }
//                    viewModel.saveShift {
//                        vibrate.toggle()
//                        dismiss()
//                    }
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
                    .padding(.horizontal)
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
                EmptyView()
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
        viewModel.shiftData.availabilities.remove(atOffsets: offsets)
    }
}

let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .none
    return formatter
}()

let timeFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .none
    formatter.timeStyle = .short
    return formatter
}()

struct ConfirmShiftView: View {
    
    private var actionConfirm: (() -> Void)?
    private var actionCancel: (() -> Void)?
    
    var body: some View {
        NavigationView {
            VStack {
                Text("YOU'RE OFFERING:")
                    .underline()
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                
                Spacer()
                
                Text("Nov 13th, 2023")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                
                Text("FLOATER_IT_CR19_PDA")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                
                Text("06:00 - 14:00")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(.secondary)
                
                Image(systemName: "arrow.up.arrow.down")
                    .fontWeight(.semibold)
                    .padding(.vertical)
                    .foregroundStyle(.accent)
                
                Text("In exchange of one of these dates:")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                
                Text("Nov 16, 2023 from 11:00 to 23:00")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("OR")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                Text("Nov 18, 2023 from 5:00 to 14:30")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
//                Button {
//                    
//                } label: {
//                    Label("Swipe to confirm", systemImage: "chevron.right.2")
//                        .foregroundStyle(.white)
//                        .fontWeight(.semibold)
//                        .padding(.vertical)
//                        .padding(.horizontal, 75)
//                        .background {
//                            RoundedRectangle(cornerRadius: 30)
//                        }
//                }
                SwipeToConfirmButton()
                    .onSwipeSuccess {
                        actionConfirm!()
                    }
            }
            .toolbar {
                ToolbarItem {
                    Button {
                        actionCancel!()
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

struct SwipeToConfirmButton: View {
    @State private var thumbSize: CGSize = CGSize.inactiveThumbSize
    @State private var dragOffset: CGSize = .zero
    @State private var isEnough = false
    
    private var actionSuccess: (() -> Void)?
    
    let trackSize = CGSize.trackSize
    
    var body: some View {
        
        ZStack {
            Capsule()
                .frame(width: trackSize.width, height: trackSize.height)
                .foregroundColor(Color.accent)
            
            Text("Swipe to confirm")
                .font(.caption)
                .foregroundStyle(.white)
                .offset(x: 30, y: 0)
                .opacity(Double(1 - (self.dragOffset.width*2)/self.trackSize.width))
            
            ZStack {
                Capsule()
                    .frame(width: thumbSize.width, height: thumbSize.height)
                    .foregroundStyle(.white)
                    .overlay {
                        Capsule()
                            .stroke(Color.accent, lineWidth: 2.0)
                            .frame(width: thumbSize.width, height: thumbSize.height - 1.0)
                    }
                
                Image(systemName: "arrow.right")
                    .foregroundStyle(.black)
            }
            .offset(x: getDragOffsetX(), y: 0)
            .gesture(
                DragGesture()
                    .onChanged({ value in self.handleDragChanged(value) })
                    .onEnded({ _ in self.handleDragEnded() })
            )
        }
    }
    
    private func getDragOffsetX() -> CGFloat {
        let clmapedDragOffsetX = dragOffset.width.clamp(lower: 0, trackSize.width - thumbSize.width)
        return -(trackSize.width/2 - thumbSize.width/2 - clmapedDragOffsetX)
    }
    
    private func handleDragChanged(_ value: DragGesture.Value) -> Void {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)){
            self.dragOffset = value.translation
        }
        
        let dragWidth = value.translation.width
        let targetDragWidth = self.trackSize.width - (self.thumbSize.width*2)
        let wasInitiated = dragWidth > 2
        let didReachTarget = dragWidth > targetDragWidth
        
        self.thumbSize = wasInitiated ? CGSize.activeThumbSize : CGSize.inactiveThumbSize
        
        if didReachTarget {
            self.isEnough = true
        } else {
            self.isEnough = false
        }
    }
    
    private func handleDragEnded() -> Void {
        if isEnough {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                dragOffset = CGSize(width: trackSize.width - thumbSize.width, height: 0)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                self.actionSuccess!()
            }
        } else {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                dragOffset = .zero
                thumbSize = CGSize.inactiveThumbSize
            }
        }
    }
}

extension SwipeToConfirmButton {
    func onSwipeSuccess(_ action : @escaping () -> Void) -> Self {
        var this = self
        this.actionSuccess = action
        return this
    }
}

//#Preview {
//    Text("Bruv")
//        .sheet(isPresented: .constant(true), content: {
//            ConfirmationView(didConfirm: .constant(false))
//                .presentationDetents([.medium])
//        })
//}

#Preview {
    TabViewManager_Previews.PreviewWrapper(selectedTab: 0)
}

