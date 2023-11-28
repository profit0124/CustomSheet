//
//  BasicIdeaView.swift
//  CustomBottomSheet
//
//  Created by Sooik Kim on 11/28/23.
//

import SwiftUI

struct BasicIdeaView: View {
    
    @State var offset: CGFloat = 0
    @State var previousOffset: CGFloat = 0
    @GestureState var dragGestureOffset: CGFloat = 0
    
    @State var isPresent: Bool = false
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)){
                    isPresent.toggle()
                }
            }, label: {
                Text(isPresent ? "Close" : "Open")
            })
            
            
            // Sheet
            GeometryReader{ proxy -> AnyView in
                let height = proxy.frame(in: .global).height
                return AnyView(
                    ZStack {
                        Color.red
                        
                        VStack {
                            Capsule()
                                .fill(Color.white)
                                .frame(width: 80, height: 5)
                                .padding(.top)
                        }
                        .padding(.horizontal)
                        .frame(maxHeight: .infinity, alignment: .top)
                        
                        VStack {
                            // Something Contents
                        }
                    }
                        .onAppear {
                            print(height)
                        }
                        
                        .offset(y: isPresent ? height / 2 + 50 : height)
                        .offset(y: !isPresent ? 0 : offset)
                        .gesture(
                            DragGesture()
                                .updating($dragGestureOffset, body: { value, out, _ in
                                    out = value.translation.height
                                    let tempOffset = dragGestureOffset + previousOffset
                                    if -tempOffset < height / 2 {
                                        DispatchQueue.main.async {
                                            self.offset = dragGestureOffset + previousOffset
                                        }
                                    }
                                })
                                .onEnded({ value in
                                    withAnimation {
                                        if -offset > (height / 2 - 50) / 2 {
                                            offset = -(height / 2)
                                        } else if  -offset < 0 {
                                            offset = 0
                                            self.isPresent.toggle()
                                        } else {
                                            offset = 0
                                        }
                                    }
                                    self.previousOffset = self.offset
                                })
                        )
                )
                
            }
            .ignoresSafeArea()
        }
    }
}

#Preview {
    BasicIdeaView()
}
