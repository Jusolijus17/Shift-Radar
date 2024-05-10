//
//  ShiftView.swift
//  Shift Radar
//
//  Created by Justin Lefrançois on 2023-10-25.
//

import SwiftUI

struct ShiftCell: View {
    @Binding var shift: Shift
    
    var onDelete: () -> Void = { }
    var onEdit: () -> Void = { }
    var onTap: () -> Void = { }
    var showsMoreActions: Bool = false
    var showsOffers: Bool = false
    
    @State var showActions: Bool = false
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            HStack {
                VStack {
                    HStack {
                        Text("\(shift.start, formatter: dateFormatter)")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(.tertiary)
                        Spacer()
                        Text(offeredSince())
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Text(shift.location)
                            .fontWeight(.semibold)
                            .minimumScaleFactor(0.6)
                            .lineLimit(1)
                        Spacer()
                    }
                    HStack {
                        Text("\(shift.start, formatter: timeFormatter) - \(shift.end, formatter: timeFormatter)")
                            .foregroundStyle(.secondary)
                            .fontWeight(.semibold)
                        Spacer()
                        HStack(spacing: 5) {
                            Image(systemName: getIcon())
                                .fontWeight(.semibold)
                                .foregroundStyle(.accent)
                            Text(exchangeType())
                                .foregroundStyle(.secondary)
                        }
                        .font(.caption)
                    }
                }
                .contentShape(Rectangle())
                .blur(radius: showActions ? 3 : 0)
                
            }
            .padding(15)
            .clipShape(RoundedRectangle(cornerRadius: 5))
            .overlay {
                if showActions {
                    blurOverlay
                }
            }
            .background {
                RoundedRectangle(cornerRadius: 20)
                    .fill(.white)
                    .stroke(Color.accentColor.opacity(0.5))
            }
            
            if showsOffers && shift.pendingOffers > 0 {
                HStack(spacing: 5) {
                    Text("\(shift.pendingOffers) new offer\(shift.pendingOffers > 1 ? "s" : "")")
                    Image(systemName: "chevron.right")
                }
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .padding(.horizontal, 15)
                .padding(.vertical, 5)
                .background {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(.red)
                }
                .offset(y: -15)
            }
        }
        .onTapGesture {
            if showsMoreActions {
                withAnimation {
                    showActions.toggle()
                }
            } else {
                onTap()
            }
        }
    }
    
    private var blurOverlay: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(.gray.opacity(0.4))
            .overlay {
                HStack(spacing: 50) {
                    Button {
                        onEdit()
                    } label: {
                        Image(systemName: "pencil")
                            .font(.title2)
                            .padding(10)
                            .background {
                                Color.blue
                            }
                            .foregroundStyle(.white)
                            .clipShape(Circle())
                    }
                    Button {
                        onDelete()
                    } label: {
                        Image(systemName: "trash")
                            .font(.title3)
                            .padding(10)
                            .background {
                                Color.red
                            }
                            .foregroundStyle(.white)
                            .clipShape(Circle())
                    }
                }
            }
    }
    
    private func getIcon() -> String {
        switch shift.compensation.type {
        case .give:
            return "gift"
        case .sell:
            return "dollarsign"
        case .trade:
            return "arrow.triangle.2.circlepath"
        }
    }
    
    private func exchangeType() -> String {
        switch shift.compensation.type {
        case .give:
            return "Giving"
        case .sell:
            return "Selling for \(Int(shift.compensation.amount ?? 0))$"
        case .trade:
            return "Trading"
        }
    }
    
    private func offeredSince() -> String {
        let daysSince = daysSinceOffer()
        
        if daysSince == 0 {
            return "Offered today"
        } else if daysSince == 1 {
            return "Offered yesterday"
        } else {
            return "Offered \(daysSince)d ago"
        }
    }

    private func daysSinceOffer() -> Int {
        let calendar = Calendar.current
        let startDate = calendar.startOfDay(for: shift.offeredDate ?? Date())
        let endDate = calendar.startOfDay(for: Date())
        let components = calendar.dateComponents([.day], from: startDate, to: endDate)
        return components.day ?? 0
    }

}

extension ShiftCell {
    func onDelete(_ action: @escaping () -> Void) -> Self {
        var copy = self
        copy.onDelete = action
        return copy
    }
    func onEdit(_ action: @escaping () -> Void) -> Self {
        var copy = self
        copy.onEdit = action
        return copy
    }
    func onTap(_ action: @escaping () -> Void) -> Self {
        var copy = self
        copy.onTap = action
        return copy
    }
    func showMoreActions() -> Self {
        var copy = self
        copy.showsMoreActions = true
        return copy
    }
    func showOffers() -> Self {
        var copy = self
        copy.showsOffers = true
        return copy
    }
}

#Preview {
    ShiftCell(shift: .constant(Shift()))
        .showMoreActions()
        .showOffers()
}
