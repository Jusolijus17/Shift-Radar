//
//  PositionSelector.swift
//  Shift Radar
//
//  Created by Justin Lefrançois on 2023-12-28.
//

import SwiftUI
import FirebaseDatabase

class PositionSelectorModel: ObservableObject {
    @Published var positions: [String] = []
    
    var positionFilter: FilterOption? {
        didSet {
            self.filterPositions()
        }
    }
    var locationFilter: FilterOption? {
        didSet {
            self.filterPositions()
        }
    }
    
    private var lastOptionsUpdate: TimeInterval {
        get { UserDefaults.standard.double(forKey: "lastOptionsUpdate") }
        set { UserDefaults.standard.set(newValue, forKey: "lastOptionsUpdate") }
    }
    
    init() {
        loadMenuOptionsIfNeeded()
    }
    
    func filterPositions() {
        let allOptions = getCachedMenuOptions()

        let filteredOptions = allOptions.filter { option in
            let matchesPosition = positionFilter == nil || positionFilter!.filterValues.contains { option.contains($0) }
            let matchesLocation = locationFilter == nil || locationFilter!.filterValues.contains { option.contains($0) }
            return matchesPosition && matchesLocation
        }

        DispatchQueue.main.async {
            self.positions = filteredOptions.sorted()
        }
    }
    
    // MARK: Private functions
    
    private func cacheMenuOptions(options: [String]) {
        UserDefaults.standard.set(options, forKey: "cachedMenuOptions")
    }
    
    private func getCachedMenuOptions() -> [String] {
        return UserDefaults.standard.stringArray(forKey: "cachedMenuOptions") ?? []
    }
    
    private func loadMenuOptionsIfNeeded() {
        let ref = Database.database().reference(withPath: "dynamicData/locations/lastUpdated")
        ref.observeSingleEvent(of: .value, with: { snapshot in
            if let timestamp = snapshot.value as? TimeInterval, timestamp > self.lastOptionsUpdate {
                self.loadMenuOptions()
                self.lastOptionsUpdate = timestamp
            } else {
                self.positions = self.getCachedMenuOptions().sorted()
            }
        })
    }
    
    private func loadMenuOptions() {
        let ref = Database.database().reference(withPath: "dynamicData/locations/options")
        ref.observeSingleEvent(of: .value, with: { snapshot in
            var newOptions: [String] = []
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot,
                   let value = snapshot.value as? String {
                    newOptions.append(value)
                }
            }
            DispatchQueue.main.async {
                self.positions = newOptions.sorted()
                self.cacheMenuOptions(options: newOptions)
            }
        })
    }
}

struct PositionSelector: View {
    @Binding var positionFilter: FilterOption?
    @Binding var locationFilter: FilterOption?
    @Binding var selection: String?
    
    @StateObject private var model = PositionSelectorModel()
    
    var body: some View {
        ZStack {
            if model.positions.isEmpty {
                // Afficher le message "No positions found"
                Text("No positions found")
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 15)
                    .onAppear {
                        selection = nil
                    }
            } else {
                Picker("", selection: $selection) {
                    ForEach(model.positions, id: \.self) {
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
                .onAppear {
                    selection = model.positions[0]
                }
            }
        }
        .frame(height: 50)
        .onChange(of: positionFilter) {
            model.positionFilter = positionFilter
        }
        .onChange(of: locationFilter) {
            model.locationFilter = locationFilter
        }
    }
}

#Preview {
    PositionSelector(positionFilter: .constant(FilterOption(displayName: "Test", filterValues: [""])), locationFilter: .constant(FilterOption(displayName: "Test", filterValues: [""])), selection: .constant(""))
}
