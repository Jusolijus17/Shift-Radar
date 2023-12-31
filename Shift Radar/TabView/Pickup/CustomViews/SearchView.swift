//
//  SearchView.swift
//  Shift Radar
//
//  Created by Justin Lefrançois on 2023-12-29.
//

import SwiftUI

struct SearchView: View {
    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var isCleared = true
    @State private var showRecentSearches = false
    @State private var recentSearches: [(startDate: Date, endDate: Date)] = []
    
    var onSearch: (Date?, Date?) -> Void = { _, _ in }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 15) {
                ZStack {
                    HStack {
                        Spacer()
                        Menu {
                            ForEach(recentSearches.indices, id: \.self) { index in
                                Button {
                                    let search = recentSearches[index]
                                    self.startDate = search.startDate
                                    self.endDate = search.endDate
                                    self.search()
                                } label: {
                                    Text("\(searchDisplay(for: recentSearches[index]))")
                                }
                            }
                        } label: {
                            HStack {
                                Image(systemName: "clock.arrow.circlepath")
                                Text("Recent searches")
                                    .font(.headline)
                                Image(systemName: "chevron.down")
                            }
                        }
                        .menuOrder(.priority)
                        Spacer()
                    }
                    .padding(.horizontal)
                    HStack {
                        Spacer()
                        Button {
                            self.clearSearch()
                        } label: {
                            Image(systemName: "xmark")
                                .foregroundStyle(Color.gray)
                                .padding(8)
                                .background {
                                    Circle()
                                        .fill(Color(uiColor: .secondarySystemBackground))
                                }
                        }
                    }
                    .opacity(isCleared ? 0 : 1)
                    .disabled(isCleared)
                }
                
                HStack {
                    Group {
                        VStack {
                            Text("START DATE")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            DatePicker("", selection: $startDate, displayedComponents: .date)
                        }
                        Text("TO")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .fontDesign(.rounded)
                            .foregroundStyle(.gray)
                        VStack {
                            Text("END DATE")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            DatePicker("", selection: $endDate, displayedComponents: .date)
                        }
                    }
                    .labelsHidden()
                }
                Spacer()
                    .frame(height: 0)
            }
            .padding(.bottom, 35.0)
            .padding([.top, .horizontal])
            .background()
            .cornerRadius(20)
            .shadow(radius: 10)
            .onChange(of: endDate) {
                adjustDate()
            }
            .onChange(of: startDate) {
                adjustDate()
            }
            
            Button {
                self.search()
            } label: {
                Label("Search shifts", systemImage: "magnifyingglass")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(10)
                    .background(Color.accentColor)
                    .cornerRadius(20)
            }
            .offset(y: 20)
            
            HStack {
                Spacer()
                Button {
                    
                } label: {
                    Label("Add filter", systemImage: "plus")
                        .font(.caption)
                        .padding(5)
                        .background {
                            RoundedRectangle(cornerRadius: 25.0)
                                .fill(Color(uiColor: .secondarySystemFill))
                        }
                        .padding([.trailing, .bottom], 10)
                }
            }
        }
        .padding(.bottom, 15)
    }
    
    private func adjustDate() {
        if endDate < startDate {
            endDate = startDate
        }
    }
    
    private func clearSearch() {
        self.onSearch(nil, nil)
        self.isCleared = true
    }
    
    private func search() {
        self.onSearch(self.startDate, self.endDate)
        self.isCleared = false
        saveToRecentSearches(startDate: startDate, endDate: endDate)
    }
    
    private func saveToRecentSearches(startDate: Date, endDate: Date) {
        let newSearchPair = (startDate, endDate)

        if !recentSearches.contains(where: { $0.startDate == newSearchPair.0 && $0.endDate == newSearchPair.1 }) {
            recentSearches.insert(newSearchPair, at: 0)
            if recentSearches.count > 5 {
                recentSearches = Array(recentSearches.prefix(5))
            }
        }
    }

    private func searchDisplay(for search: (startDate: Date, endDate: Date)) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return "\(formatter.string(from: search.startDate)) to \(formatter.string(from: search.endDate))"
    }

}

#Preview {
    SearchView()
}
