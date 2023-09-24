//
//  Login.swift
//  DG
//
//  Created by Scott McGhie on 2023-06-20.
//

import SwiftUI

struct Login: View {
    
    @ObservedObject var showSignInView: SignedIn
    @State private var showSignin = false
    @State private var showCreateAccount = false

    var body: some View {
        ZStack{

            Color("bgdark")
                .ignoresSafeArea()
            VStack{
                Spacer()

                Image("logo")
                    .frame(width:100, height: 100)
                Button{
                    withAnimation (.easeInOut(duration: 1)){
                        showSignin.toggle()
                    }
                    } label:{
                        if !showCreateAccount{
                            HStack{
                                Image(systemName: "envelope")
                                Text("Sign in with e-mail")
                            }
                            .font(.headline)
                            .frame(width:185)
                            .frame(height:35)
                            .cornerRadius(10)
                        }
                }
                if showSignin{
                    LoginEmail(showSignInView: showSignInView)
                        .animation(.easeInOut(duration: 2))
                }
                Button{
                    withAnimation (.easeInOut(duration: 1)){
                        showCreateAccount.toggle()
                    }
                    } label:{
                        if !showSignin{
                            HStack{
                                Image(systemName: "person.badge.plus")
                                Text("Create account")
                            }
                            .padding()
                            .font(.headline)
                            .frame(width:185)
                            .frame(height:35)
                            .cornerRadius(10)
                        }
                }
                if showCreateAccount{
                    CreateAccount(showSignInView: showSignInView)
                        .animation(.easeInOut(duration: 2))
                }
                Spacer()
            }
        }
        .foregroundColor(Color("contentfont"))
        .toolbarBackground(Color("menudark"), for: .navigationBar)
    }
}


struct Login_Previews: PreviewProvider {
    static var previews: some View {
        Login(showSignInView: SignedIn())
            .previewDevice(PreviewDevice(rawValue: "iPhone 14 Pro Max"))
            .previewDisplayName("iPhone 14 Pro Max")
        Login(showSignInView: SignedIn())
            .previewDevice(PreviewDevice(rawValue: "iPhone 14 Pro"))
            .previewDisplayName("iPhone 14 Pro")
    }
}
