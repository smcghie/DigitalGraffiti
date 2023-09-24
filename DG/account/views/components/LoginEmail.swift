//
//  LoginEmail.swift
//  DG
//
//  Created by Scott McGhie on 2023-06-20.
//

import SwiftUI

@MainActor
final class LoginEmailViewModel: ObservableObject {
    
    @Published var email = ""
    @Published var password = ""
    @Published var username = ""
    @StateObject var quertArt = QueryArt()
    
    func signIn() async throws {
        
        guard !email.isEmpty, !password.isEmpty else {
            print("No email or password found")
            return
        }
        try await AuthenticationManager.shared.signInUser(email: email, password: password)
    }
}

struct LoginEmail: View {
    
    @StateObject private var viewModel = LoginEmailViewModel()
    @ObservedObject var showSignInView: SignedIn
    @State private var secured: Bool = true

    var body: some View {
        VStack {
            
            TextField("Email...", text: $viewModel.email)
                .padding()
                .cornerRadius(10)
                .background(Color.gray.opacity(0.4))
            ZStack(alignment: .trailing){
                if secured{
                    SecureField("Password...", text: $viewModel.password)
                        .padding()
                        .cornerRadius(10)
                        .background(Color.gray.opacity(0.4))
                }else{
                    TextField("Password...", text: $viewModel.password)
                        .padding()
                        .cornerRadius(10)
                        .background(Color.gray.opacity(0.4))
                }
                Button(action: {
                    secured.toggle()
                }) {
                    Image(systemName: self.secured ? "eye.slash" : "eye")
                        .accentColor(.gray)
                }
                .padding(.trailing, 20)
            }
            Button{
                Task {
                    do {
                        try await viewModel.signIn()
                        showSignInView.showSignInView = false
                        return
                    } catch{
                        print(error)
                    }
                }
            } label: {
                Text("Login")
                    .font(.headline)
                    .foregroundColor(Color("contentfont"))
                    .frame(height:55)
                    .frame(maxWidth: .infinity)
                    .background(Color("itembg"))
                    .cornerRadius(10)
            }
        }
        .animation(nil)
        .padding()
    }
}

struct LoginEmail_Previews: PreviewProvider {
    static var previews: some View {
        LoginEmail(showSignInView: SignedIn())
    }
}
