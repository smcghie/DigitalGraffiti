//
//  ChatList.swift
//  DG
//
//  Created by Scott McGhie on 2023-07-28.
//

import SwiftUI

struct ChatList: View {
    
    @StateObject var messagesManager = MessagesManager()
    @EnvironmentObject var userMonitor: UserMonitor
    @State private var showingConfirmation = false

    var body: some View {
        List{
            ForEach(messagesManager.conversations){ conversation in

                ChatRow(conversation: conversation)
                    .swipeActions {
                        Button("DELETE") {
                            showingConfirmation = true
                        }
                        .tint(Color("titlemain"))
                    }
                    .confirmationDialog("Delete conversation", isPresented: $showingConfirmation) {
                        Button("Delete") {
                            messagesManager.deleteConversation(conversationId: conversation.id)
                        }
                    } message: {
                        Text("Permanently delete conversation?")
                    }
            }
            .listRowSeparator(.hidden)
            .listRowBackground(Color("bgdark"))
        }
        .overlay(Group {
            if(messagesManager.conversations.isEmpty) {
                ZStack() {
                    Color("bgdark").ignoresSafeArea()
                    VStack{
                        Image(systemName: "tray")
                            .font(.system(size: 60))
                            .padding()
                        Text("No Messages")
                    }
                }
            }
        })
        .listStyle(PlainListStyle())
        .scrollContentBackground(.hidden)
        .background(Color("bgdark"))
        .navigationBarTitle("Chats", displayMode: .inline).font(.headline)
        .foregroundColor(Color("contentfont"))
        .toolbarBackground(.visible, for: .tabBar)
        .toolbarBackground(Color("menudark"), for: .tabBar)
        .onAppear{
            messagesManager.getAllConversations(userId: userMonitor.uI)
        }
    }
}

//struct ChatList_Previews: PreviewProvider {
//    static var previews: some View {
//        ChatList()
//            .environmentObject(UserMonitor())
//    }
//}
