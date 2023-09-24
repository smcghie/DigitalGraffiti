//
//  ContentView.swift
//  DigitalGratiffi
//
//  Created by Scott McGhie on 2021-11-19.
//


import SwiftUI

struct ARContentView: View {
    
    var artwork: Artwork

    var body: some View {
        CustomController(artwork: artwork)
            .toolbar(.hidden, for: .tabBar)

    }
}

struct CustomController: UIViewControllerRepresentable{
    @State var artwork: Artwork

    func makeUIViewController(context: UIViewControllerRepresentableContext<CustomController>) -> UIViewController {
        let storyboard = UIStoryboard(name: "ArtPreview", bundle: Bundle.main)
        let controller = storyboard.instantiateViewController(identifier: "ARViewController") as! ARViewController
        controller.artwork = artwork
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context:
                                UIViewControllerRepresentableContext<CustomController>){
    }
}


