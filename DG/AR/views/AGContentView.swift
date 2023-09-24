//
//  ContentView.swift
//  DigitalGratiffi
//
//  Created by Scott McGhie on 2021-11-19.
//


import SwiftUI

struct AGContentView: View {

    var artwork: Artwork!
    @ObservedObject var queryArt: QueryArt
    var userId: String!
    
    var body: some View {
        CustomController1(artwork: artwork, queryArt: queryArt, userId: userId)
            .toolbar(.hidden, for: .tabBar)

    }
}
struct CustomController1: UIViewControllerRepresentable {
    @State var artwork: Artwork
    @ObservedObject var queryArt: QueryArt
    @State var userId: String
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<CustomController1>) -> UIViewController {
        let storyboard = UIStoryboard(name: "ArtGallery", bundle: Bundle.main)
        let controller = storyboard.instantiateViewController(identifier: "AGViewController") as! AGViewController
        controller.artwork = artwork
        controller.queryArt = queryArt
        controller.userId = userId
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context:
                                UIViewControllerRepresentableContext<CustomController1>){
    }

}

