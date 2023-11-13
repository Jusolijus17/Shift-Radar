//
//  CustomObjects.swift
//  Shift Radar
//
//  Created by Justin Lefrançois on 2023-11-06.
//

import SwiftUI

struct BoxSelector: View {
    let options: [String]
    @State private var selectedOption: String?
    
    var selectionChanged: (String?) -> Void = { _ in }
    
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
                            if selectedOption == option {
                                selectedOption = nil
                                selectionChanged(nil)
                            } else {
                                selectedOption = option
                                selectionChanged(option)
                            }
                        }
                    }
                    .sensoryFeedback(.impact, trigger: selectedOption)
            }
        }
    }
}

extension BoxSelector {
    func onSelectionChanged(_ selection: @escaping (String?) -> Void) -> Self {
        var copy = self
        copy.selectionChanged = selection
        return copy
    }
}

struct CustomSecureField: View {
    @Binding var text: String
    var placeholder: String
    var systemName: String

    var body: some View {
        HStack {
            Image(systemName: systemName)
                .foregroundColor(.gray)
            SecureField(placeholder, text: $text)
        }
    }
}

struct CustomSlider: View {
    @Binding var value: Double
    var range: ClosedRange<Double>
    var step: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Slider(value: $value, in: range, step: step)
                    .padding(.vertical)
                Text("\(Int(value))$")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(.secondary)
                    .frame(width: 35, height: 20)
                    .offset(x: self.sliderOffset(sliderWidth: geometry.size.width), y: -30)
            }
            .sensoryFeedback(.impact(intensity: 0.8), trigger: value)
        }
        .frame(height: 30)
    }
    
    private func sliderOffset(sliderWidth: CGFloat) -> CGFloat {
        let sliderRange = range.upperBound - range.lowerBound
        let sliderStep = CGFloat((value - range.lowerBound) / sliderRange)
        return sliderStep * (sliderWidth - 35) // 35 is the approximate width of the Text view
    }
}

struct CustomTextField: View {
    @Binding var text: String
    var placeholder: String
    var systemName: String

    var body: some View {
        HStack {
            Image(systemName: systemName)
                .foregroundColor(Color(hex: "#A3A3A3"))
            TextField(placeholder, text: $text)
        }
    }
}

struct SimpleIconSelection: View {
    var icons: [Image]
    var fillColor: Color
    
    @State private var selectedIconIndices: Set<Int> = []

    var body: some View {
        HStack {
            ForEach(icons.indices, id: \.self) { index in
                Group {
                    if selectedIconIndices.contains(index) {
                        icons[index]
                            .foregroundColor(fillColor)
                    } else {
                        icons[index]
                            .foregroundColor(Color.gray.opacity(0.5))
                    }
                }
                .onTapGesture {
                    if selectedIconIndices.contains(index) {
                        selectedIconIndices.remove(index)
                    } else {
                        selectedIconIndices.insert(index)
                    }
                }
            }
        }
        .padding(7)
        .background(
            RoundedRectangle(cornerRadius: 5)
                .stroke(Color.gray.opacity(0.5), lineWidth: 1)  // Ajout d'une bordure
        )
    }
}
