//
//  HomePage.swift
//  Shift Radar
//
//  Created by Justin Lefrançois on 2023-10-24.
//

import SwiftUI

struct PickupShiftView: View {
    var body: some View {
        VStack {
            SearchView()
                .padding()
            Spacer()
            HStack {
                Text("Your picked up shifts")
                    .font(.subheadline)
                Spacer()
                Button(action: {
                    
                }, label: {
                    Image(systemName: "line.3.horizontal")
                        .font(.title2)
                        .foregroundStyle(.gray)
                })
                Button(action: {
                    
                }, label: {
                    Image(systemName: "line.3.horizontal.decrease")
                        .font(.title2)
                        .foregroundStyle(.gray)
                })
            }
            .padding(.horizontal)
            ScrollView {
                VStack(spacing: 10) {  // 10 est l'espacement entre chaque ShiftView
                    ForEach(0..<10) { _ in  // Ceci affichera 10 ShiftViews
                        ShiftView()
                            .padding(.horizontal)
                    }
                }
            }
        }
    }
}

struct SearchView: View {
    @State private var fromText: String = ""
    @State private var toText: String = ""
    @State private var dateSelection: Date? = nil
    @State var selectedDate: Date = Date()
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 15) {
                HStack {
                    Spacer()
                    Image(systemName: "clock.arrow.circlepath")
                    Text("Recent searches")
                        .font(.headline)
                    Image(systemName: "chevron.down")
                    Spacer()
                }
                .padding(.horizontal)
                
                ZStack {
                    HStack {
                        CustomTextField(text: $fromText, placeholder: "From", systemName: "arrowshape.zigzag.right")
                            .padding(.horizontal)
                            .frame(height: 40)
                            .overlay(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                            )
                        
                        CustomTextField(text: $toText, placeholder: "To", systemName: "arrow.forward.to.line")
                            .padding(.horizontal)
                            .frame(height: 40)
                            .overlay(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                            )
                    }
                    .padding(.horizontal)
                    
                    Button {
                        // Votre action ici
                    } label: {
                        Image(systemName: "arrow.left.arrow.right")
                            .resizable()
                            .frame(width: 15, height: 15)
                            .foregroundStyle(.gray)
                            .padding(8)
                            .background {
                                Circle()
                                    .fill(Color.white)
                                    .stroke(.gray.opacity(0.5), lineWidth: 1)
                            }
                    }

                    
                }
                
                ZStack {
                    DatePicker("label", selection: $selectedDate, displayedComponents: [.date])
                        .datePickerStyle(CompactDatePickerStyle())
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .labelsHidden()
                    Label("Select dates", systemImage: "calendar")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        .foregroundStyle(Color.accentColor)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                                .frame(height: 40)
                        )
                        .userInteractionDisabled()
                }
                .frame(height: 40)
                .padding(.horizontal)
                
                //                Button(action: {}) {
                //                    Label("Select dates", systemImage: "calendar")
                //                        .padding(.horizontal)
//                        .frame(maxWidth: .infinity, minHeight: 40, alignment: .leading)
//                        .overlay(
//                            RoundedRectangle(cornerRadius: 5)
//                                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
//                        )
//                }
//                .padding(.horizontal)
                
                HStack {
                    let icons = [
                        Image(systemName: "sun.max.fill"),
                        Image(systemName: "moon.fill"),
                        Image(systemName: "airplane"),
                        Image(systemName: "bag.fill")
                    ]
                    SimpleIconSelection(icons: icons, fillColor: .accentColor)
                    
                    Spacer()
                    
                    Button(action: {}) {
                        Label("Add filter", systemImage: "plus")
                            .padding(7)
                            .overlay {
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.green)
                            }
                    }
                    .foregroundStyle(.green)
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 35.0)
            .padding([.top, .horizontal])
            .background()
            .cornerRadius(20)
            .shadow(radius: 10)
            
            Button(action: {}) {
                Label("Search shifts", systemImage: "magnifyingglass")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(10)
                    .background(Color.accentColor)
                    .cornerRadius(20)
                    .frame(maxWidth: .infinity)
                    .offset(y: 20)
            }
        }
        .padding(.bottom, 15)
    }
}

struct DatePickerButtonView: View {
    @State private var isDatePickerShown = false
    @State private var selectedDate = Date()

    var body: some View {
        VStack {
            Button(action: {
                isDatePickerShown = true
            }) {
                HStack {
                    Image(systemName: "calendar")
                    Text("Select Dates")
                }
                .padding(.horizontal)
                .frame(maxWidth: .infinity, minHeight: 40, alignment: .leading)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                )
            }
            .padding(.horizontal)
            .sheet(isPresented: $isDatePickerShown) {
                VStack {
                    DatePicker("Select Date", selection: $selectedDate, displayedComponents: [.date])
                        .datePickerStyle(GraphicalDatePickerStyle())
                        .padding()
                    Button("Done") {
                        isDatePickerShown = false
                    }
                    .padding()
                }
            }
        }
    }
}

#Preview {
    TabViewManager_Previews.previews
}
