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
        Group {
            if viewModel.isEmpty {
                NoOfferView(showModal: $viewModel.showModal)
                    .sheet(isPresented: $viewModel.showModal) {
                        OfferShiftModalView()
                            .presentationDetents([.medium])
                            .tint(.secondary.opacity(0.5))
                    }
            } else {
                VStack {
                    Text("Offers here...")
                }
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
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                HStack {
                    VStack(alignment: .leading) {
                        Text("START TIME")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                        DatePicker("", selection: $viewModel.startTime, displayedComponents: .hourAndMinute)
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
                        DatePicker("", selection: $viewModel.endTime, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                            .tint(.accent)
                    }
                    VStack(alignment: .leading) {
                        Text("8H")
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
                    Text("POPULAR:")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(.secondary)
                    BoxSelector(options: ["RAMP", "FLOATER", "BAGROOM"]) { selection in
                        // Do something after tapping
                    }
                }
                Picker("", selection: $viewModel.location) {
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
            .padding(.horizontal, 35)
            .toolbar(content: {
                ToolbarItem {
                    Button {
                        dismiss()
                    } label: {
                        Label("Dismiss", systemImage: "xmark.circle.fill")
                    }
                }
            })
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
                            selectedOption = option
                            selectionChanged(option)
                        }
                    }
                    .sensoryFeedback(.impact, trigger: selectedOption)
            }
        }
    }
}


#Preview {
    TabViewManager_Previews.PreviewWrapper(selectedTab: 1)
}
