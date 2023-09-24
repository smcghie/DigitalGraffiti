//
//  TabBar.swift
//  DG
//
//  Created by Scott McGhie on 2023-06-20.
//

import SwiftUI

class TagMonitor: ObservableObject {
    @Published var selectedTag = 1
}

@MainActor
class UserMonitor: ObservableObject{
    @Published var uI: String = ""
    @Published var user: String?
    @Published var username: UserProfile?

    func checkUser() async throws{
        let userID = try? AuthenticationManager.shared.getAuthenticatedUser().uid
        uI = userID!
    }
    
    func getUsername(artistID: String) async throws {
        self.username = try await QueryArt.shared.getUsername(artist: artistID)
        user = username!.name
    }
}

class ViewManager: ObservableObject {
    @Published var profileRoot: UUID = UUID()
    @Published var wallRoot: UUID = UUID()
    
    var isUpdated: Bool = false {
        didSet{
            profileRoot = UUID()
        }
    }
    var isSignedOut: Bool = false {
        didSet{
            wallRoot = UUID()
        }
    }
}

struct TabBar: View {
    @StateObject private var tagMonitor = TagMonitor()
    @StateObject private var userMonitor = UserMonitor()
    @ObservedObject var showSignInView: SignedIn
    @ObservedObject private var viewManager = ViewManager()
    @State var isHiding : Bool = false
    @State var scrollOffset : CGFloat = 0
    @State var threshHold : CGFloat = 0
    var body: some View {
        VStack {
                TabView(selection: $tagMonitor.selectedTag){
                    TabBarView(tag: 1){
                            WallView(text: "", showSignInView: .constant(false))
                    }
                        .tabItem{Image(systemName: "house")}
                        .tag(1)
                        .toolbar(.hidden, for: .navigationBar)
                    TabBarView(tag: 2){
                        ProfilePage(artistId: userMonitor.uI)
                    }
                        .tabItem{Image(systemName: "person.crop.circle")}
                        .tag(2)
                    TabBarView(tag: 3){
                        ChatList()
                    }
                        .tabItem{Image(systemName: "paperplane.fill")}
                        .tag(3)
                    SettingsView(showSignInView: showSignInView, selectedTab: $tagMonitor.selectedTag)
                        .tabItem{Image(systemName: "gearshape")}
                        .tag(4)
                }
                .environmentObject(viewManager)
                .environmentObject(tagMonitor)
                .environmentObject(userMonitor)
        }
        .tint(Color("titlemain"))
        .onAppear{
            showSignInView.showSignInView = true
            Task{
                try await userMonitor.checkUser()
                print(userMonitor.username)
            }
        }
        .onReceive(showSignInView.$showSignInView, perform: { _ in
            Task{
                if showSignInView.showSignInView == false {
                    try? await userMonitor.checkUser()
                    try? await self.userMonitor.getUsername(artistID: userMonitor.uI)
                }
            }
        })
    }
}

struct TabBarView: View {
    
    @EnvironmentObject var currentTag: TagMonitor
    private var tag: Int
    private var currentView: AnyView
    @State private var id = 1
    @State private var selected = false

    init(tag: Int, @ViewBuilder _ content: () -> any View) {
        self.tag = tag
        self.currentView = AnyView(content())
    }

    var body: some View {
        NavigationView {
            currentView
                .id(id)
                .onReceive(currentTag.$selectedTag) { current in
                    if current != tag {
                        selected = false
                    } else {
                        if selected {
                            id *= -1
                        }
                        selected = true
                    }
                }
        }
    }
}

//struct TabBar_Previews: PreviewProvider {
//    static var previews: some View {
//        TabBar(showSignInView: SignedIn())
//            .environmentObject(ViewManager())
//            .environmentObject(TagMonitor())
//            .environmentObject(UserMonitor())
//    }
//}
