//
//  CustomSheetModifier.swift
//  CustomBottomSheet
//
//  Created by Sooik Kim on 11/28/23.
//

import SwiftUI

struct CustomSheetModifier<SheetContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    
    @State var offset: CGFloat = 0
    @State var previousOffset: CGFloat = 0
    @GestureState var dragGestureOffset: CGFloat = 0
    
    @State private var sheetContentHeight: CGFloat = 0
    
    @ViewBuilder let sheetContent: () -> SheetContent
    
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            if isPresented {
                Color.gray
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation{
                            isPresented = false
                        }
                    }
            }
            
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
                            CustomSheetViewContentView($sheetContentHeight, content: sheetContent)
                            Spacer()
                        }
                        .padding(.top, 30)
                    }
                    .offset(y: isPresented ? height - sheetContentHeight - 50: height)
                    .offset(y: !isPresented ? 0 : offset)
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
                                        self.isPresented.toggle()
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


struct CustomSheetViewContentView<Content>: View where Content: View {
    let content: () -> Content
    @Binding var height: CGFloat
    
    init(_ height: Binding<CGFloat>, @ViewBuilder content: @escaping () -> Content) {
        self._height = height
        self.content = content
    }
    
    var body: some View {
        self.content()
            .onReadSize{
                height = $0.height
            }
            .onChange(of: height) { old, new in
                print("old: \(old), new: \(new)")
            }
    }
}


extension View {
    @ViewBuilder
    func onReadSize(_ perform: @escaping (CGSize) -> Void) -> some View {
        self.customBackground {
            GeometryReader { geometryProxy in
                Color.clear
                  .preference(key: SizePreferenceKey.self, value: geometryProxy.size)
                }
        }
        .onPreferenceChange(SizePreferenceKey.self, perform: perform)
    }

    @ViewBuilder
    func customBackground<V: View>(alignment: Alignment = .center, @ViewBuilder content: () -> V) -> some View {
        self.background(alignment: alignment, content: content)
    }
}

struct SizePreferenceKey: PreferenceKey {
      static var defaultValue: CGSize = .zero
      static func reduce(value: inout CGSize, nextValue: () -> CGSize) { }
}


extension View {
    func customSheet(isPresented: Binding<Bool>, @ViewBuilder _ sheetContent: @escaping () -> some View) -> some View {
        modifier(CustomSheetModifier(isPresented: isPresented, sheetContent: sheetContent))
    }
}
