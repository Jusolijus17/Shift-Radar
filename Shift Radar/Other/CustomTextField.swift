//
//  CustomTextField.swift
//  Shift Radar
//
//  Created by Justin Lefrançois on 2024-05-05.
//

import SwiftUI

enum CustomFieldType: Equatable {
    case phoneNumber, employeeNumber, email,
         firstName, lastName, password, confirmPassword,
         custom(iconName: String, placeholder: String)
}

struct CustomTextField: View {
    @Binding var text: String
    var type: CustomFieldType
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        HStack {
            switch type {
            case .phoneNumber:
                Image(systemName: "phone")
                    .foregroundColor(Color(hex: "#A3A3A3"))
                TextField("Add phone number", text: $text)
                    .keyboardType(.numberPad)
                    .onReceive(text.publisher.collect()) {
                        let digits = $0.filter { $0.isNumber }
                        if digits.count > 10 {
                            self.text = formatPhoneNumber(String(digits.prefix(10)))
                        } else {
                            self.text = formatPhoneNumber(String(digits))
                        }
                    }
                    .focused($isTextFieldFocused)
                
            case .employeeNumber:
                Label("AC", systemImage: "number")
                    .foregroundStyle(.tertiary)
                Divider()
                    .frame(maxHeight: 25)
                    .padding(.horizontal, 5)
                TextField("Employee number", text: $text)
                    .keyboardType(.numberPad)
                    .focused($isTextFieldFocused)

            case .email:
                Image(systemName: "envelope")
                    .foregroundColor(Color(hex: "#A3A3A3"))
                TextField("Email", text: $text)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .focused($isTextFieldFocused)
                Text("@aircanada.ca")
                    .foregroundStyle(Color.gray)
                    .padding(.trailing, 10)
                
            case .firstName, .lastName:
                let icon = type == .firstName ? "person.fill" : "person"
                let placeholder = type == .firstName ? "First name" : "Last name"
                Image(systemName: icon)
                    .foregroundColor(Color(hex: "#A3A3A3"))
                TextField(placeholder, text: $text)
                    .focused($isTextFieldFocused)

            case .custom(let iconName, let customPlaceholder):
                Image(systemName: iconName)
                    .foregroundColor(Color(hex: "#A3A3A3"))
                TextField(customPlaceholder, text: $text)
                    .focused($isTextFieldFocused)

            case .password, .confirmPassword:
                let placeholder = type == .password ? "Password" : "Confirm Password"
                let icon = type == .password ? "lock" : "lock.fill"
                Image(systemName: icon)
                    .foregroundColor(Color(hex: "#A3A3A3"))
                SecureField(placeholder, text: $text)
                    .focused($isTextFieldFocused)
            }
        }
        .contentShape(Rectangle()) // Assure que tout le HStack est touchable
        .onTapGesture {
            self.isTextFieldFocused = true
        }
    }
    
    func outlined(color: Color = .accentColor.opacity(0.5), cornerRadius: CGFloat = 10.0, lineWidth: CGFloat = 1) -> some View {
        modifier(Outlined(color: color, cornerRadius: cornerRadius, lineWidth: lineWidth))
    }
    
    private func formatPhoneNumber(_ number: String) -> String {
        guard number.filter({ $0.isNumber }).count <= 10 else { return number }
        let cleanNumber = number.filter { $0.isNumber }
        let mask = "XXX-XXX-XXXX"

        var result = ""
        var index = cleanNumber.startIndex
        for ch in mask where index < cleanNumber.endIndex {
            if ch == "X" {
                result.append(cleanNumber[index])
                index = cleanNumber.index(after: index)
            } else {
                result.append(ch)
            }
        }
        return result
    }
}


struct Outlined: ViewModifier {
    var color: Color = .accentColor.opacity(0.5)
    var cornerRadius: CGFloat = 10.0
    var lineWidth: CGFloat = 1

    func body(content: Content) -> some View {
        content
            .padding()
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color.white)
                    .shadow(color: color.opacity(0.1), radius: 1, x: 0, y: 2)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(color, lineWidth: lineWidth)
                    )
            )
    }
}

#Preview {
    CustomTextField(text: .constant(""), type: .firstName)
        .outlined()
        .padding()
}
