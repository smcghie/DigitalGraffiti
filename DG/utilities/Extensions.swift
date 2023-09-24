//
//  Extensions.swift
//  DG
//
//  Created by Scott McGhie on 2023-08-13.
//

import Foundation
import SwiftUI

extension View {
    
    func hideBars(proxy : GeometryProxy, currentOffset : Binding<CGFloat>,
        changeThreshold : Binding<CGFloat>, toggle: Binding<Bool>) -> some View {
        self
            .onChange(of: proxy.frame(in: .named("scroll")).minY) { newValue in
                currentOffset.wrappedValue = abs(newValue)
                if currentOffset.wrappedValue > changeThreshold.wrappedValue + 150 {
                    changeThreshold.wrappedValue = currentOffset.wrappedValue
                    toggle.wrappedValue = true
                }else if currentOffset.wrappedValue < changeThreshold.wrappedValue - 150 {
                    changeThreshold.wrappedValue = currentOffset.wrappedValue
                    toggle.wrappedValue = false
                }
         }
    }
    
    func Print(_ vars: Any...) -> some View {
        for v in vars { print(v) }
        return EmptyView()
    }
    
    func freeRotation() -> some View {
        onAppear {
            AppDelegate.orientationLock = UIInterfaceOrientationMask.allButUpsideDown
            UIViewController.attemptRotationToDeviceOrientation()
            
        }
        .onDisappear {
            AppDelegate.orientationLock = UIInterfaceOrientationMask.portrait
            UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
            UIViewController.attemptRotationToDeviceOrientation()
        }
    }
    
    @ViewBuilder
    func cropImagePicker(show: Binding<Bool>, croppedImage: Binding<UIImage?>) -> some View{
        CustomImagePicker(show: show, croppedImage:croppedImage){
            self
        }
    }
    
    @ViewBuilder
    func frame(_ size: CGSize)-> some View{
        self
            .frame(width: size.width, height: size.height)
    }

    func haptics(_ style: UIImpactFeedbackGenerator.FeedbackStyle){
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }
    
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
