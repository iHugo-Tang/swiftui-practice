//
//  ContentView.swift
//  DynamicDotsExample
//
//  Created by Hugo L on 2024/11/27.
//

import SwiftUI

import SwiftUI

struct ContentView: View {
    
    // MARK: - Private Properties
    
    @State private var currentIndex1 = 0
    @State private var currentIndex = 0
    
    private let colors: [Color] = [.red, .blue, .green, .yellow]
    
    // MARK: - Body
    
    var body: some View {
        TabView(selection: $currentIndex) {
            ForEach(0..<colors.count, id: \.self) { index in
                colors[index]
                    .tag(index)
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .overlay(alignment: .bottom) {
            DynamicDotsView(currentIndex: $currentIndex1, pageControlIndex: $currentIndex)
                .padding(.bottom, 22)
        }
        .onChange(of: currentIndex) { oldValue, newValue in
            guard currentIndex != currentIndex1 else { return }
            withAnimation {
                currentIndex1 = currentIndex
            }
        }
    }
}

#Preview {
    ContentView()
}

