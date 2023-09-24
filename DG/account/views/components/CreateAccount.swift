//
//  LoginEmail.swift
//  DG
//
//  Created by Scott McGhie on 2023-06-20.
//

import SwiftUI

@MainActor
final class CreateAccountViewModel: ObservableObject {
    
    @Published var email = ""
    @Published var password = ""
    @Published var username = ""
    @Published var aImage: UIImage?
    var queryArt = QueryArt()

    func signUp(aImage: UIImage?) async throws {
        
        guard !email.isEmpty, !password.isEmpty, !username.isEmpty, aImage != nil else {
            print("No email or password found")
            return
        }
        try await AuthenticationManager.shared.createUser(email: email, password: password)
        let userID = try? AuthenticationManager.shared.getAuthenticatedUser().uid
        try? await queryArt.uploadAvatar(artistId: userID!, aImage: aImage!, username: username)
    }
}

struct CreateAccount: View {
    
    @StateObject private var viewModel = CreateAccountViewModel()
    @ObservedObject var showSignInView: SignedIn
    @State private var showPicker: Bool = false
    @State private var croppedImage: UIImage?
    @State private var secured: Bool = true

    var body: some View {
            ZStack{
                if let croppedImage{
                    Button{
                        showPicker.toggle()
                    } label: {
                        Image(uiImage: croppedImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 150, height: 150)
                    }
                }else{
                    Button{
                        showPicker.toggle()
                    } label: {
                        Image(systemName: "photo.on.rectangle")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundColor(Color("titlemain"))

                    }
                    .padding([.top, .bottom], 50)
                }
            }
            .cropImagePicker(show: $showPicker, croppedImage: $croppedImage)
        VStack{
            TextField("E-mail...", text: $viewModel.email)
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
            TextField("Username...", text: $viewModel.username)
                .padding()
                .cornerRadius(10)
                .background(Color.gray.opacity(0.4))
            Button{
                Task {
                    do {
                        try await viewModel.signUp(aImage: croppedImage!)
                        showSignInView.showSignInView = false
                        return
                    } catch{
                        print(error)
                    }
                }
            } label: {
                Text("Create Account")
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
            Spacer()
    }
}

struct CreateAccount_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack{
            CreateAccount(showSignInView: SignedIn())
        }
    }
}
