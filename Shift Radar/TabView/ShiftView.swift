//
//  ShiftView.swift
//  Shift Radar
//
//  Created by Justin Lefrançois on 2023-10-25.
//

import SwiftUI

struct ShiftView: View {
    var body: some View {
        VStack {
            HStack {
                Image("preview1")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 50, height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                    .padding(.trailing, 10)
                VStack(alignment: .leading) {
                    Text("RAMP_D_CR39")
                        .minimumScaleFactor(0.6)
                        .lineLimit(1)
                    HStack {
                        Text("Nov 4th")
                            .foregroundStyle(.secondary)
                        Text("Sat")
                            .foregroundStyle(.tertiary)
                    }
                }
                Spacer()
                VStack(alignment: .trailing) {
                    HStack {
                        Text("06:00")
                            .fontWeight(.semibold)
                            .minimumScaleFactor(0.5)
                            .lineLimit(1)
                        Image(systemName: "arrow.forward.circle")
                            .foregroundStyle(.tertiary)
                        Text("14:00")
                            .fontWeight(.semibold)
                            .minimumScaleFactor(0.5)
                            .lineLimit(1)
                    }
                    Text("Traded for Nov 23rd")
                        .font(.caption)
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                }
                Image(systemName: "ellipsis")
                    .rotationEffect(Angle(degrees: 90.0))
            }
            .padding([.horizontal, .top])
            
            HStack {
                Spacer()
                Text("Previous owner: Justin Lefrançois")
                    .foregroundStyle(.secondary)
                    .font(.caption)
                Spacer()
                Text("(514)-771 6593")
                    .foregroundStyle(.secondary)
                    .font(.caption)
                Spacer()
            }
            .padding(5)
            .background(Color.accentColor.opacity(0.2))
        }
        .clipShape(RoundedRectangle(cornerRadius: 5))
        .background {
            RoundedRectangle(cornerRadius: 5)
                .fill(.white)
                .stroke(Color.accentColor.opacity(0.5))
        }
    }
}

#Preview {
    ShiftView()
}
