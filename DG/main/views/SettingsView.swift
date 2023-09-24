//
//  SettingsView.swift
//  DG
//
//  Created by Scott McGhie on 2023-06-20.
//

import SwiftUI

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var tempUsername = ""

    func signOut() throws {
        try AuthenticationManager.shared.signOut()
    }

    func resetPassword() async throws {
        let authUser = try AuthenticationManager.shared.getAuthenticatedUser()
        guard let email = authUser.email else {
            throw URLError(.fileDoesNotExist)
        }
        try await AuthenticationManager.shared.resetPassword(email: email)
    }

    func updateUserProfile(artistId: String, image: UIImage?, queryArt: QueryArt, userMonitor: UserMonitor) async {
        if let newImage = image {
            try? await queryArt.updateAvatar(artistId: artistId, aImage: newImage)
        }
        if !tempUsername.isEmpty {
            QueryArt.shared.updateUsername(artistId: artistId, username: tempUsername)
        }
        try? await userMonitor.getUsername(artistID: artistId)
        tempUsername = ""
    }
}

struct SettingsView: View {
    
    @StateObject private var viewModel = SettingsViewModel()
    @ObservedObject var showSignInView: SignedIn
    @StateObject var tabBar = TagMonitor()
    @StateObject var queryArt = QueryArt()
    @Binding var selectedTab: Int
    @EnvironmentObject var userMonitor: UserMonitor
    @State private var showPicker: Bool = false
    @State private var croppedImage: UIImage?

    var body: some View {
        VStack {
            userProfileSection
            usernameTextFieldSection
            settingsList
        }
        .onDisappear {
            viewModel.tempUsername = ""
            croppedImage = nil
        }
        .navigationTitle("Settings")
        .listStyle(PlainListStyle())
        .scrollContentBackground(.hidden)
        .background(Color("bgdark"))
        .foregroundColor(Color("contentfont"))
        .toolbarBackground(.visible, for: .tabBar)
        .toolbarBackground(Color("menudark"), for: .tabBar)
    }

    private var userProfileSection: some View {
        Group{
            if let user = userMonitor.username {
                SettingsUserProfileSection(showPicker: $showPicker, croppedImage: $croppedImage, avatarUrl: user.avatarUrl)
            }else{
                EmptyView()
            }
        }
    }

    private var usernameTextFieldSection: some View {
        HStack {
            TextField(text: $viewModel.tempUsername) {
                Text(userMonitor.username!.name)
                    .foregroundColor(Color("contentfont"))
            }
            .multilineTextAlignment(.center)
        }
    }

    private var settingsList: some View {
        List {
            saveProfileButton
            signOutButton
            resetPasswordButton
        }
        .onReceive(queryArt.$uploaded) { _ in
            Task {
                try? await userMonitor.getUsername(artistID: userMonitor.username!.id)
            }
        }
    }

    private var saveProfileButton: some View {
        Group{
            if croppedImage != nil || !viewModel.tempUsername.isEmpty {
                SettingsListButton(title: "Save Profile") {
                    Task {
                        await viewModel.updateUserProfile(artistId: userMonitor.username!.id, image: croppedImage, queryArt: queryArt, userMonitor: userMonitor)
                        croppedImage = nil
                    }
                }
            }else{
                EmptyView()
            }
        }
    }

    private var signOutButton: some View {
        SettingsListButton(title: "Sign Out") {
            Task {
                do {
                    selectedTab = 1
                    try viewModel.signOut()
                    showSignInView.showSignInView = true
                } catch {
                    print(error)
                }
            }
        }
    }

    private var resetPasswordButton: some View {
        SettingsListButton(title: "Reset Password") {
            Task {
                do {
                    try await viewModel.resetPassword()
                    print("Password Reset")
                } catch {
                    print(error)
                }
            }
        }
    }
}

struct SettingsUserProfileSection: View {
    @Binding var showPicker: Bool
    @Binding var croppedImage: UIImage?
    var avatarUrl: String

    var body: some View {
        Button {
            showPicker.toggle()
        } label: {
            if let croppedImage = croppedImage {
                Image(uiImage: croppedImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 150, height: 150)
            } else {
                AsyncImage(url: URL(string: avatarUrl)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 150, height: 150)
                }
                placeholder: {}
            }
        }
        .cropImagePicker(show: $showPicker, croppedImage: $croppedImage)
    }
}

struct SettingsListButton: View {
    var title: String
    var action: () -> Void

    var body: some View {
        Button(title, action: action)
            .listRowBackground(Color("bgdark"))
    }
}

//struct SettingsView_Previews: PreviewProvider {
//    @Binding var selectedTab: Int
//    @EnvironmentObject var userMonitor: UserMonitor
//    var username: UserProfile?
//
//
//    static var previews: some View {
//        NavigationStack{
//            SettingsView(showSignInView: SignedIn(), selectedTab: .constant(3))
//        }
//    }
//}
