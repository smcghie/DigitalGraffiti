//
//  WallView.swift
//  DG
//
//  Created by Scott McGhie on 2023-06-20.
//

import SwiftUI

struct WallView: View {
    @State var text: String
    @Binding var showSignInView: Bool
    @State var isHiding : Bool = false
    @State var scrollOffset : CGFloat = 0
    @State var changeThreshold : CGFloat = 0
    var body: some View {
        
        ScrollView(.vertical, showsIndicators: false){
            ZStack{
                Wall()
                GeometryReader { proxy in
                    Color.clear
                        .hideBars(
                            proxy: proxy,
                            currentOffset: $scrollOffset,
                            changeThreshold: $changeThreshold,
                            toggle: $isHiding
                        )
                }
                .toolbar(isHiding ? .hidden : .visible, for: .tabBar).animation(.linear)
                .toolbar(isHiding ? .hidden : .visible, for: .navigationBar).animation(.linear)
            }
        }
        .onDisappear{
            isHiding = false
        }
        .coordinateSpace(name: "scroll")
        .toolbar {
            ToolbarItem(placement: .principal) {
                Image("logo")
                    .resizable()
                    .scaledToFit()
            }
        }
        .safeAreaInset(edge: .top, spacing: 0, content: {
            Color.clear
                .frame(height: 0)
                .background(.bar)
                .border(Color("menudark"))
        })
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.visible, for: .tabBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(Color("menudark"), for: .navigationBar)
        .toolbarBackground(Color("menudark"), for: .tabBar)
        .background(Color("bgdark"))
        .tint(Color("titlemain"))
    }
}

struct WallView_Previews: PreviewProvider {
    static var previews: some View {
        WallView(text: "", showSignInView: .constant(false)).environmentObject(ViewManager())
            .preferredColorScheme(.light)
        WallView(text: "", showSignInView: .constant(false)).environmentObject(ViewManager())
            .preferredColorScheme(.dark)
    }
}
