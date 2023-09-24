//
//  ChatRow.swift
//  DG
//
//  Created by Scott McGhie on 2023-07-28.
//

import SwiftUI
import CachedAsyncImage

@MainActor
final class ChatRowViewModel: ObservableObject {
    @Published var username: UserProfile = UserProfile(id: "", name: "", avatarUrl: "")
    
    func getUsername(artistID: String) async throws -> UserProfile{
        let username = try await QueryArt.shared.getUsername(artist: artistID)
        return username
    }
}

struct ChatRow: View {
    
    var conversation: Conversation?
    @StateObject var viewModel = ChatRowViewModel()
    @EnvironmentObject var userMonitor: UserMonitor
    @StateObject var messagesManager = MessagesManager()

    var body: some View {
        HStack{
            VStack{
                HStack{
                    AsyncImage(url: URL(string : viewModel.username.avatarUrl)) { image in
                        NavigationLink{ChatScreen(viewModel: ChatViewModel(userId: userMonitor.uI, username: viewModel.username, image:image, conversation: conversation))
                        } label: {
                        image
                            .resizable()
                            .frame(width: 50, height: 50)
                        VStack{
                            HStack{
                                Text("\(viewModel.username.name)")
                                    .font(.headline)
                                    .foregroundColor(Color("titlemain"))
                                    .padding(.bottom, 1)
                                Spacer()
                            }
                            HStack{
                                Text(viewModel.username.name == userMonitor.username!.name ? "" : "You: ")
                                    .font(.footnote)
                                    .foregroundColor(Color("subtitlemain"))

                                Text("\(conversation!.lastMsg)").lineLimit(1)
                                    .font(.footnote)
                                    .foregroundColor(Color("subtitlemain"))
                                Spacer()
                            }
                        }
                        .padding(.leading, 1)
                        Spacer()
                        VStack{
                            Text("• \(conversation!.lastMessageTimeStamp.formatted(.dateTime.hour().minute()))")
                                .foregroundColor(Color("subtitlemain"))
                                .font(.callout)
                        }
                    }
                    } placeholder: {
                        ProgressView()
                    }
                }
                .padding(.bottom, 10)
            }
        }
        .onAppear{
            Task{
                let username = try? await viewModel.getUsername(artistID: userMonitor.uI == conversation!.participant1 ? conversation!.participant2 : conversation!.participant1)
                viewModel.username = username!
            }
        }
    }
}

