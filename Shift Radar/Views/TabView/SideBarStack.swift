//
//  SideMenu.swift
//  Shift Radar
//
//  Created by Justin Lefrançois on 2024-01-16.
//

import SwiftUI

struct SideBarStack<SidebarContent: View, Content: View>: View {
    
    let sidebarContent: SidebarContent
    let mainContent: Content
    let sidebarWidth: CGFloat
    @Binding var showSidebar: Bool
    
    init(sidebarWidth: CGFloat, showSidebar: Binding<Bool>, @ViewBuilder sidebar: ()->SidebarContent, @ViewBuilder content: ()->Content) {
        self.sidebarWidth = sidebarWidth
        self._showSidebar = showSidebar
        sidebarContent = sidebar()
        mainContent = content()
    }
    
    var body: some View {
        ZStack(alignment: .trailing) {
            Color(hex: "2a2a2a")
                .ignoresSafeArea()
            sidebarContent
                .frame(width: sidebarWidth, alignment: .center)
                .offset(x: showSidebar ? 0 : sidebarWidth, y: 0)
            mainContent
                .clipShape(
                    RoundedRectangle(cornerRadius: showSidebar ? 55 : 0)
                )
                .overlay(
                    Group {
                        if showSidebar {
                            Color.white
                                .opacity(showSidebar ? 0.01 : 0)
                                .onTapGesture {
                                    withAnimation {
                                        self.showSidebar = false
                                    }
                                }
                        } else {
                            Color.clear
                                .opacity(showSidebar ? 0 : 0)
                                .onTapGesture {
                                    withAnimation {
                                        self.showSidebar = false
                                    }
                                }
                        }
                    }
                )
                .ignoresSafeArea()
                .offset(x: showSidebar ? -sidebarWidth : 0, y: 0)
            
        }
    }
}
