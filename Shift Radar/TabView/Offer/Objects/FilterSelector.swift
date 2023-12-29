//
//  FilterSelector.swift
//  Shift Radar
//
//  Created by Justin Lefrançois on 2023-12-28.
//

import SwiftUI

struct FilterOption: Equatable {
    let displayName: String
    let filterValues: [String]
}

struct FilterSelector: View {
    @Binding var filters: [FilterOption]
    @State private var selectedFilter: FilterOption?
    
    var filterChanged: (FilterOption?) -> Void = { _ in }
    
    var body: some View {
        HStack {
            ForEach($filters, id: \.wrappedValue.displayName) { $filter in
                let filterValue = $filter.wrappedValue
                Text(filterValue.displayName)
                    .font(.system(size: 12, design: .rounded))
                    .padding(5)
                    .background {
                        RoundedRectangle(cornerRadius: 5)
                            .fill(selectedFilter?.displayName == filterValue.displayName ? Color.accentColor : Color.clear)
                            .strokeBorder(style: StrokeStyle(lineWidth: selectedFilter?.displayName == filterValue.displayName ? 0 : 1, dash: [4, 4]))
                    }
                    .foregroundColor(selectedFilter?.displayName == filterValue.displayName ? Color.white : .secondary)
                    .onTapGesture {
                        withAnimation {
                            if selectedFilter?.displayName == filterValue.displayName {
                                selectedFilter = nil
                                filterChanged(nil)
                            } else {
                                selectedFilter = filterValue
                                filterChanged(filterValue)
                            }
                        }
                    }
                    .sensoryFeedback(.impact, trigger: $selectedFilter.wrappedValue)
            }
        }
    }
}

extension FilterSelector {
    func onFilterChanged(_ filter: @escaping (FilterOption?) -> Void) -> Self {
        var copy = self
        copy.filterChanged = filter
        return copy
    }
}


#Preview {
    FilterSelector(filters: .constant([FilterOption(displayName: "FLOATER", filterValues: ["FLOATER"])]))
}
