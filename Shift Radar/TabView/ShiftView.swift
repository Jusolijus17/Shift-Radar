//
//  ShiftView.swift
//  Shift Radar
//
//  Created by Justin Lefrançois on 2023-10-25.
//

import SwiftUI

//struct ShiftView: View {
//    var body: some View {
//        VStack {
//            HStack {
//                Image("preview1")
//                    .resizable()
//                    .aspectRatio(contentMode: .fill)
//                    .frame(width: 50, height: 50)
//                    .clipShape(RoundedRectangle(cornerRadius: 5))
//                    .padding(.trailing, 10)
//                VStack(alignment: .leading) {
//                    Text("RAMP_D_CR39")
//                        .minimumScaleFactor(0.6)
//                        .lineLimit(1)
//                    HStack {
//                        Text("Nov 4th")
//                            .foregroundStyle(.secondary)
//                        Text("Sat")
//                            .foregroundStyle(.tertiary)
//                    }
//                }
//                Spacer()
//                VStack(alignment: .trailing) {
//                    HStack {
//                        Text("06:00")
//                            .fontWeight(.semibold)
//                            .minimumScaleFactor(0.5)
//                            .lineLimit(1)
//                        Image(systemName: "arrow.forward.circle")
//                            .foregroundStyle(.tertiary)
//                        Text("14:00")
//                            .fontWeight(.semibold)
//                            .minimumScaleFactor(0.5)
//                            .lineLimit(1)
//                    }
//                    Text("Traded for Nov 23rd")
//                        .font(.caption)
//                        .minimumScaleFactor(0.5)
//                        .lineLimit(1)
//                }
//                Image(systemName: "ellipsis")
//                    .rotationEffect(Angle(degrees: 90.0))
//            }
//            .padding([.horizontal, .top])
//
//            HStack {
//                Spacer()
//                Text("Previous owner: Justin Lefrançois")
//                    .foregroundStyle(.secondary)
//                    .font(.caption)
//                Spacer()
//                Text("(514)-771 6593")
//                    .foregroundStyle(.secondary)
//                    .font(.caption)
//                Spacer()
//            }
//            .padding(5)
//            .background(Color.accentColor.opacity(0.2))
//        }
//        .clipShape(RoundedRectangle(cornerRadius: 5))
//        .background {
//            RoundedRectangle(cornerRadius: 5)
//                .fill(.white)
//                .stroke(Color.accentColor.opacity(0.5))
//        }
//    }
//}

struct ShiftView: View {
    @Binding var hasOffer: Bool
    @Binding var shift: Shift
    
    var onDelete: (_ id: String?) -> Void
    
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
                
                Menu {
                    Button(role: .destructive) {
                        onDelete(shift.id)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                    Button {
                        
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                    .menuOrder(.priority)
                } label: {
                    Image(systemName: "ellipsis")
                        .rotationEffect(.degrees(90.0))
                        .tint(.black)
                        .padding(5)
                }

            }
            .padding([.vertical, .leading], 15)
            .padding(.trailing, 5)
            .clipShape(RoundedRectangle(cornerRadius: 5))
            .background {
                RoundedRectangle(cornerRadius: 20)
                    .fill(.white)
                    .stroke(Color.accentColor.opacity(0.5))
            }
            if hasOffer {
                HStack(spacing: 5) {
                    Text("1 offer")
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
    }
    
    private func getIcon() -> String {
        switch shift.compensationType {
        case .give:
            return "gift"
        case .sell:
            return "dollarsign"
        case .trade:
            return "arrow.triangle.2.circlepath"
        }
    }
    
    private func exchangeType() -> String {
        switch shift.compensationType {
        case .give:
            return "Giving"
        case .sell:
            return "Selling for \(Int(shift.moneyCompensation))$"
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
        let startDate = calendar.startOfDay(for: shift.offeredDate)
        let endDate = calendar.startOfDay(for: Date())
        let components = calendar.dateComponents([.day], from: startDate, to: endDate)
        return components.day ?? 0
    }

}

#Preview {
    ShiftView(hasOffer: .constant(true), shift: .constant(Shift()), onDelete: { _ in })
}
