//
//  Shapes.swift
//  Shift Radar
//
//  Created by Justin Lefrançois on 2023-10-27.
//

import SwiftUI

struct SyncSpinner: View {
    @State var borderInit: Bool = false
    @State var spinArrow: Bool = false
    @State var dismissArrow: Bool = false
    @State var displayCheckmark: Bool = false
    
    var body: some View {
        ZStack {
            // Border
            Circle()
                .strokeBorder(style: StrokeStyle(lineWidth: borderInit ? 10 : 64))
                .frame(width: 128, height: 128)
                .foregroundColor(borderInit ? .green : .black)
            
            // Checkmark
            Path { path in
                path.move(to: CGPoint(x: 20, y: -40))
                path.addLine(to: CGPoint(x: 40, y: -20))
                path.addLine(to: CGPoint(x: 80, y: -60))
            }
            .trim(from: 0, to: displayCheckmark ? 1 : 0)
            .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round))
            .foregroundColor(displayCheckmark ? .green : .black)
            .offset(x: 150, y: 420)
        }
        .onAppear {
            launchAnimations()
        }
    }
    
    func launchAnimations() {
        withAnimation(.easeOut(duration: 3).speed(1.5)) {
            borderInit.toggle()
        }
        withAnimation(.easeOut(duration: 2)) {
            spinArrow.toggle()
        }
        withAnimation(.easeInOut(duration: 1).delay(1)) {
            dismissArrow.toggle()
        }
        withAnimation(.spring(.bouncy, blendDuration: 2).delay(2)) {
            displayCheckmark.toggle()
        }
    }
}


#Preview {
    SyncSpinner()
}
