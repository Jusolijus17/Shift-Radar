//
//  ProfileBar.swift
//  Vibes
//
//  Created by Justin Lefrançois on 2022-09-28.
//

import SwiftUI

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


struct SimpleIconSelection_Previews: PreviewProvider {
    static var previews: some View {
        let items = [
            Image(systemName: "house.fill"),
            Image(systemName: "house.fill"),
            Image(systemName: "house.fill")
        ]
        
        SimpleIconSelection(icons: items, fillColor: .cyan)
    }
}
