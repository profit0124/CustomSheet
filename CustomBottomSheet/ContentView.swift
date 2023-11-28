//
//  ContentView.swift
//  CustomBottomSheet
//
//  Created by Sooik Kim on 2023/09/07.
//

import SwiftUI

struct ContentView: View {
    @State private var height: CGFloat = 0
    
    @State private var isPresented: Bool = false
    
    var body: some View {
//        BasicIdeaView()
        Text(isPresented ? "Close" : "Open")
            .onTapGesture {
                withAnimation {
                    isPresented.toggle()                    
                }
            }
            .customSheet(isPresented: $isPresented) {
                VStack {
                    Color.blue
                        .frame(height: 15)
                    Color.black
                        .frame(height: 300)
                    Color.blue
                        .frame(height: 15)
                }
                .padding(30)
                .background {
                    Color.yellow
                }
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
