//
//  RootView.swift
//  DG
//
//  Created by Scott McGhie on 2023-06-20.
//

import SwiftUI

class SignedIn: ObservableObject {
    @Published var showSignInView = false
}

struct RootView: View {
    
    @StateObject private var showSignInView = SignedIn()

    var body: some View {
        TabBar(showSignInView: showSignInView)
            .preferredColorScheme(.dark)
        .onAppear{
            let authUser = try? AuthenticationManager.shared.getAuthenticatedUser()
            self.showSignInView.showSignInView = authUser == nil
        }
        .fullScreenCover(isPresented: $showSignInView.showSignInView){
            NavigationStack{
                Login(showSignInView: showSignInView)
            }
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
