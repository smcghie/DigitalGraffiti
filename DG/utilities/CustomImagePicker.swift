//
//  CustomImagePicker.swift
//  DG
//
//  Created by Scott McGhie on 2023-07-18.
//

import SwiftUI
import PhotosUI

class ImageHolder: ObservableObject {
    @Published var image: UIImage?
}

struct CustomImagePicker<Content: View>: View {
    
    var content: Content
    @Binding var show:Bool
    @Binding var croppedImage: UIImage?
    
    init(show: Binding<Bool>, croppedImage: Binding<UIImage?>,
        @ViewBuilder content: @escaping ()->Content){
        self.content = content()
        self._show = show
        self._croppedImage = croppedImage
    }
    @StateObject var imageholder = ImageHolder()
    @State private var photosItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var showCropView: Bool = false
    
    var body: some View {
        content
            .photosPicker(isPresented: $show, selection: $photosItem)
            .onChange(of: photosItem) { _ in
                Task {
                    if let imageData = try? await photosItem!.loadTransferable(type: Data.self) {
                        if let image = UIImage(data: imageData) {
                            selectedImage = image
                            showCropView.toggle()
                            imageholder.image = selectedImage
                        }
                    }
                }
            }
            .fullScreenCover(isPresented: $showCropView){
                selectedImage = nil
            }content:{
                CropView(image: imageholder.image){ croppedImage, status in
                    if let croppedImage{
                        self.croppedImage = croppedImage
                    }
                }
            }
    }
}

struct CropView: View{
    
    var image: UIImage?
    var cropped: (UIImage?, Bool)->()
    
    @Environment(\.dismiss) private var dismiss
    @State private var scale: CGFloat = 1
    @State private var lastScale: CGFloat = 0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    @GestureState private var isInteracting: Bool = false
    
    var body: some View{
        NavigationStack{
            ImageView()
                .navigationTitle("Resize Picture")
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(.visible, for: .navigationBar)
                .toolbarBackground(Color("menudark"), for: .navigationBar)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background{
                    Color("menudark")
                        .ignoresSafeArea()
                }
                .toolbar{
                    ToolbarItem(placement: .navigationBarTrailing){
                        Button{
                            let renderer = ImageRenderer(content: ImageView())
                            if let image = renderer.uiImage{
                                cropped(image, true)
                            }else{
                                cropped(nil, false)
                            }
                            dismiss()
                        } label: {
                            Image(systemName: "checkmark")
                                .font(.callout)
                                .fontWeight(.semibold)
                        }
                    }
                    ToolbarItem(placement: .navigationBarLeading){
                        Button{
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.callout)
                                .fontWeight(.semibold)
                        }
                    }
                }
        }
    }
    @ViewBuilder
    func ImageView() -> some View{
        let editSize = CGSize(width:350, height: 350)
        GeometryReader{
            let size = $0.size
            if let image{
                Image(uiImage: image)
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
                    withAnimation(.easeInOut(duration: 0.2)){
                        if scale < 1{
                            scale = 1
                            lastScale = 0
                        }else{
                            lastScale = scale - 1
                        }
                    }
                })
        )
        .frame(editSize)
        .cornerRadius(editSize.height / 2)
    }
}

struct CustomImagePicker_Previews: PreviewProvider {
    static var previews: some View {
        CropView(image: UIImage(named:"pp2")) { _, _ in
        }
    }
}
