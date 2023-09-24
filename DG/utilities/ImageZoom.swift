//
//  ImageZoom.swift
//  DG
//
//  Created by Scott McGhie on 2023-08-13.
//

import SwiftUI

struct ImageZoom: View {
    
    @Environment(\.dismiss) private var dismiss
    @State private var scale: CGFloat = 1
    @State private var lastScale: CGFloat = 0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    @State var editSize = CGSize(width: UIScreen.main.bounds.width, height: .zero)
    @GestureState private var isInteracting: Bool = false
    @Binding var image: Image?
    
    var body: some View {
        ZStack{
        NavigationStack{
            ImageView()
                .ignoresSafeArea()
                .toolbarBackground(.hidden, for: .navigationBar)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background{
                    Color("menudark")
                        .ignoresSafeArea()
                }
            }
            VStack{
            Spacer()
            Button{
                dismiss()
            }label: {
                Image(systemName: "xmark")
                    .frame(width:30, height: 30)
                    .background(Color.black.opacity(0.2))
                    .cornerRadius(20)
            }
        }
        }.freeRotation()}
    
    @ViewBuilder
    func ImageView() -> some View{
        GeometryReader{
            let size = $0.size
            if let image{
                image
                    .renderingMode(.original)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .overlay(content: {
                        GeometryReader{ proxy in
                            let rect = proxy.frame(in: .named ("EDITVIEW"))
                            Color.clear
                                .onChange(of: isInteracting){ newValue in
                                    withAnimation(.easeInOut(duration: 0.3)){
                                        if rect.minX > 0 {
                                            offset.width = (offset.width - rect.minX)
                                            haptics(.medium)
                                        }
                                        if rect.minY > 0 {
                                            offset.height = (offset.height - rect.minY)
                                            haptics(.medium)
                                        }
                                        if rect.maxX < size.width{
                                            offset.width = (rect.minX - offset.width)
                                            haptics(.medium)
                                        }
                                        if rect.maxY < size.height{
                                            offset.height = (rect.minY - offset.height)
                                            haptics(.medium)
                                        }
                                    }
                                    if !newValue{
                                        lastOffset = offset
                                    }
                                }
                        }
                    })
                    .frame(size)
            }
        }
        .frame(editSize)
        .onChange(of: UIDevice.current.orientation.rawValue, perform: { value in
            if value == 1{
                editSize = CGSize(width: UIScreen.main.bounds.width, height: .zero)
            }else if value == 4 || value == 3 {
                editSize = CGSize(width: .zero, height: UIScreen.main.bounds.height)
            }
        })
        .scaleEffect(scale)
        .offset(offset)
        .coordinateSpace(name: "EDITVIEW")
        .gesture(
            DragGesture()
                .updating($isInteracting, body: { _, out, _ in
                    out = true
                }).onChanged({value in
                    let translation = value.translation
                    offset = CGSize(width: translation.width + lastOffset.width,
                        height: translation.height + lastOffset.height)
                })
        )
        .gesture(
            MagnificationGesture()
                .updating($isInteracting, body: { _, out, _ in
                    out = true
                }).onChanged({ value in
                    let updatedScale = value + lastScale
                    scale = (updatedScale < 1 ? 1 : updatedScale)
                }).onEnded({ value in
                    withAnimation(.easeInOut(duration: 0.2)) {
                        if scale < 1 {
                            scale = 1
                            lastScale = 0
                        }else{
                            lastScale = scale - 1
                        }
                    }
                })
        )
    }
}

//struct ImageZoom_Preview: PreviewProvider {
//    static var previews: some View {
//        ZoomedImage()
//    }
//}
