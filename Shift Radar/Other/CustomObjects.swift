//
//  CustomObjects.swift
//  Shift Radar
//
//  Created by Justin Lefrançois on 2023-11-06.
//

import SwiftUI

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

struct Outlined: ViewModifier {
    var color: Color = .accentColor.opacity(0.5)
    var cornerRadius: CGFloat = 10.0
    var lineWidth: CGFloat = 1

    func body(content: Content) -> some View {
        content
            .padding()
            .background {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.white)
                    .stroke(color, lineWidth: lineWidth)
            }
    }
}

extension CustomTextField {
    func outlined(color: Color = .accentColor.opacity(0.5), cornerRadius: CGFloat = 10.0, lineWidth: CGFloat = 1) -> some View {
        modifier(Outlined(color: color, cornerRadius: cornerRadius, lineWidth: lineWidth))
    }
}

struct EmployeeNumberField: View {
    @Binding var number: String
    
    var body: some View {
        HStack {
            Label("AC", systemImage: "number")
                .foregroundStyle(.tertiary)
            Divider()
                .frame(maxHeight: 25)
                .padding(.horizontal, 5)
            TextField("Employee Number", text: $number)
                .keyboardType(.numberPad)
        }
    }
}

extension EmployeeNumberField {
    func outlined(color: Color = .accentColor.opacity(0.5), cornerRadius: CGFloat = 10.0, lineWidth: CGFloat = 1) -> some View {
        modifier(Outlined(color: color, cornerRadius: cornerRadius, lineWidth: lineWidth))
    }
}

struct PullToRefresh: View {
    
    var coordinateSpaceName: String
    var onRefresh: ()->Void
    
    @State var needRefresh: Bool = false
    
    var body: some View {
        GeometryReader { geo in
            if (geo.frame(in: .named(coordinateSpaceName)).midY > 50) {
                Spacer()
                    .onAppear {
                        needRefresh = true
                    }
            } else if (geo.frame(in: .named(coordinateSpaceName)).maxY < 10) {
                Spacer()
                    .onAppear {
                        if needRefresh {
                            needRefresh = false
                            onRefresh()
                        }
                    }
            }
            HStack {
                Spacer()
                if needRefresh {
                    ProgressView()
                } else {
                    Text("⬇️")
                }
                Spacer()
            }
        }.padding(.top, -50)
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

struct SwipeToConfirmButton: View {
    @State private var thumbSize: CGSize = CGSize.inactiveThumbSize
    @State private var dragOffset: CGSize = .zero
    @State private var isEnough = false
    @State private var showLoading = false
    @Binding var resetState: Bool
    var alternateText: String?
    
    private var actionSuccess: (() -> Void)?
    
    let trackSize = CGSize.trackSize
    
    init(alternateText: String? = nil, resetState: Binding<Bool> = .constant(false)) {
        self._resetState = resetState
        self.alternateText = alternateText
    }
    
    var body: some View {
        
        ZStack {
            Capsule()
                .frame(width: trackSize.width, height: trackSize.height)
                .foregroundColor(Color.accent)
            
            Text(alternateText != nil ? alternateText! : "Swipe to confirm")
                .font(.subheadline)
                .foregroundStyle(.white)
                .offset(x: 30, y: 0)
                .opacity(Double(1 - (self.dragOffset.width*2)/self.trackSize.width))
            
            ZStack {
                Capsule()
                    .frame(width: thumbSize.width, height: thumbSize.height)
                    .foregroundStyle(.white)
                    .overlay {
                        Capsule()
                            .stroke(Color.accent, lineWidth: 2.0)
                            .frame(width: thumbSize.width, height: thumbSize.height - 2.0)
                    }
                
                if !showLoading {
                    Image(systemName: "arrow.right")
                        .foregroundStyle(.black)
                } else {
                    ProgressView()
                }
            }
            .offset(x: getDragOffsetX(), y: 0)
            .gesture(
                DragGesture()
                    .onChanged({ value in self.handleDragChanged(value) })
                    .onEnded({ _ in self.handleDragEnded() })
            )
        }
        .onChange(of: resetState) { _, newValue in
            if newValue {
                reset()
                resetState = false
            }
        }
    }
    
    func reset() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            dragOffset = .zero
            thumbSize = CGSize.inactiveThumbSize
            showLoading = false
        }
    }
    
    private func getDragOffsetX() -> CGFloat {
        let clmapedDragOffsetX = dragOffset.width.clamp(lower: 0, trackSize.width - thumbSize.width)
        return -(trackSize.width/2 - thumbSize.width/2 - clmapedDragOffsetX)
    }
    
    private func handleDragChanged(_ value: DragGesture.Value) -> Void {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)){
            self.dragOffset = value.translation
        }
        
        let dragWidth = value.translation.width
        let targetDragWidth = self.trackSize.width - (self.thumbSize.width*2)
        let wasInitiated = dragWidth > 2
        let didReachTarget = dragWidth > targetDragWidth
        
        self.thumbSize = wasInitiated ? CGSize.activeThumbSize : CGSize.inactiveThumbSize
        
        if didReachTarget {
            self.isEnough = true
        } else {
            self.isEnough = false
        }
    }
    
    private func handleDragEnded() -> Void {
        if isEnough {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                dragOffset = CGSize(width: trackSize.width - thumbSize.width, height: 0)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                if let actionSuccess = actionSuccess {
                    showLoading = true
                    actionSuccess()
                }
            }
        } else {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                dragOffset = .zero
                thumbSize = CGSize.inactiveThumbSize
            }
        }
    }
}

extension SwipeToConfirmButton {
    func onSwipeSuccess(_ action : @escaping () -> Void) -> Self {
        var this = self
        this.actionSuccess = action
        return this
    }
    
    func resetState(_ reset: Binding<Bool>) -> Self {
        var button = self
        button._resetState = reset
        return button
    }
}

struct ProfileImage<Placeholder: View>: View {
    var userData: UserData?
    var placeholder: () -> Placeholder
    
    init(userData: UserData?, @ViewBuilder placeholder: @escaping () -> Placeholder) {
        self.userData = userData
        self.placeholder = placeholder
    }
    
    var body: some View {
        Group {
            if let urlString = userData?.profileImageUrl, let url = URL(string: urlString) {
                AsyncImage(url: url) { image in
                    image.resizable()
                } placeholder: {
                    ProgressView()
                }
                .clipShape(Circle())
            } else {
                placeholder()
            }
        }
    }
}

struct EditableProfileImage: ViewModifier {
    func body(content: Content) -> some View {
        content
            .overlay {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.green)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
            }
    }
}

extension ProfileImage {
    func editable() -> some View {
        modifier(EditableProfileImage())
    }
}

#Preview {
    //SwipeToConfirmButton()
//    CustomTextField(text: .constant(""), placeholder: "First name", systemName: "person.fill")
//        .outlined()
    ProfileImage(userData: nil) {
        Image(systemName: "person.crop.circle.fill")
            .resizable()
            .scaledToFit()
            .frame(width: 100, height: 100)
            .clipShape(Circle())
    }
    .editable()
}
