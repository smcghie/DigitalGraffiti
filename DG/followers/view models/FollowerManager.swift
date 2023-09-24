//
//  FollowerManager.swift
//  DG
//
//  Created by Scott McGhie on 2023-07-30.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

@MainActor
class FollowerManager: ObservableObject {
    
    @Published private(set) var followers: [UserProfile] = []
    @Published private(set) var following: [UserProfile] = []
    @Published private(set) var followerCount = 0
    @Published private(set) var followingCount = 0
    
    let db = Firestore.firestore().collection("followers")
    
    func addFollower(artistId: String, follower1: UserProfile, follower2: UserProfile){
        do{
            try db.document("followers")
                .collection(artistId).document(follower1.id).setData(from: follower1, merge: false)
            try db.document("following")
                .collection(follower1.id).document(artistId).setData(from: follower2, merge: false)
        }catch{
            print("error adding follower: \(error)")
        }
    }
    
    func getFollowers(userId: String) async throws {
        followers = try await db.document("followers")
            .collection(userId).getDocuments(as: UserProfile.self)
    }
    
    func getFollowersCount(userId: String) async throws -> Int{
        let query = db.document("followers").collection(userId)
        let countQuery = query.count
        do{
            let snapshot = try await countQuery.getAggregation(source: .server)
            return Int(truncating: snapshot.count)
        }catch{
            print("error counting followers: \(error)")
            return 0
        }
    }
    
    func getFollowing(userId: String) async throws {
        following = try await db.document("following")
            .collection(userId).getDocuments(as: UserProfile.self)
    }
    
    func getFollowingCount(userId: String) async throws -> Int {
        let query = db.document("following").collection(userId)
        let countQuery = query.count
        do{
            let snapshot = try await countQuery.getAggregation(source: .server)
            print("follower count: ", snapshot.count)
            return Int(truncating: snapshot.count)
        }catch{
            print("error counting followers: \(error)")
            return 0
        }
    }
    
    func deleteFollower(follower: String, userId: String, followerId: String){
        db.document(follower).collection(userId).document(followerId).delete(){ err in
            if let err = err {
              print("Error deleting follower/following \(err)")
            }
            else {
              print("Follower/Following deleted")
            }
          }
    }
}
