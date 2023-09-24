//
//  QueryArt.swift
//  DigitalGratiffi
//
//  Created by Scott McGhie on 2022-11-24.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift
import FirebaseFirestore
import FirebaseStorage


var currentCards2: [Artwork] = []
var galleryCards: [ARArtwork] = []
var dlNodePosition: [NodeData] = []
var counter = 0

class QueryArt: ObservableObject{
    
    @Published var artsCards1: [Artwork] = []
    @Published var isImagePickerPresented = false
    @Published var artName = ""
    @Published var desc = ""
    @Published var image: UIImage?
    @Published var artistId = ""
    @Published var artistName = ""
    @Published var isOnGallery = false
    @Published var isLoading = false
    @Published var tags:[String] = []
    @Published var errorMessage: String?
    @Published var imageArray: [UIImage] = []
    @Published var uImage: UIImage?
    @Published var aImage: UIImage?
    @Published var updated: Bool = false
    @Published var uploaded: Bool = false
    
    var urlS: String = ""
    var thumbUrlS: String = ""
    
    class FirebaseManager: NSObject{
        let auth: Auth
        let storage: Storage
        
        static let shared = FirebaseManager()
        
        override init(){
            self.auth = Auth.auth()
            self.storage = Storage.storage()
            super.init()
        }
    }
    
    struct MyKeys{
        static let imagesFolder = "portfolioImages"
        static let avatarFolder = "avatarImages"
        static let thumbnailFolder = "thumbnailImages"
        static let galleryPreviewFolder = "galleryPreviewImages"
    }

    static let shared = QueryArt()
    
    let db = Firestore.firestore()
    let storage = Storage.storage()

    func getArtGalleries () {
        db.collection("artGalleries").document("ag1")
            .getDocument(){ (querySnapshot, err) in
                   DispatchQueue.main.async {
                       let aData = querySnapshot?.data()
                       //let mapUrl = aData!["mapUrl"] as? String ?? ""
                       let name = aData!["name"] as? [String] ?? []
                       let id = aData!["id"] as? [String] ?? []
                       let positionX = aData!["positionX"] as? [Float] ?? []
                       let positionY = aData!["positionY"] as? [Float] ?? []
                       let positionZ = aData!["positionZ"] as? [Float] ?? []
                       let nodeX = aData!["nodeX"] as? [Float] ?? []
                       let nodeY = aData!["nodeY"] as? [Float] ?? []
                       let nodeZ = aData!["nodeZ"] as? [Float] ?? []
                       let extentX = aData!["extentX"] as? [Float] ?? []
                       dlNodePosition.removeAll()
                       for i in 0...id.count-1{
                           dlNodePosition.append(NodeData(name: name[i], id: id[i], positionX: positionX[i], positionY: positionY[i], positionZ: positionZ[i], nodeX: nodeX[i], nodeY: nodeY[i], nodeZ: nodeZ[i], extentX: extentX[i]))
                       }
                }
            }
    }
    
    func getArtGallery (nodeIds: [String]) {
        galleryCards.removeAll()
        for node in nodeIds{
                db.collection("arts").document(node)
            .getDocument(){ (querySnapshot, err) in
            DispatchQueue.main.async {
                let aData = querySnapshot?.data()
                let id = querySnapshot?.documentID
                let name = counter
                let image = aData!["image"] as? String
                let artist = aData!["artist"] as? String
                let artistID = aData!["artistID"] as? String
                let description = aData!["description"] as? String
                galleryCards.append(ARArtwork(id: id!, name: name, image: image!, artist: artist!, artistID: artistID!, description: description!))
                counter += 1
            }
        }
    }
    }
    
    private let userCollection = Firestore.firestore().collection("users")
    
    func uploadUser(artistId: String, userName: String){
        userCollection.document(artistId).setData(
        [
            "id" : artistId,
            "name" : userName,
            "avatarUrl" : urlS
        ]) { err in
            if let err = err {
                print("Error writting user document: \(err)")
            }else{
                print("User successfully added")
            }
        }
    }
    
    func updateUser(artistId: String, userName: String){
        userCollection.document(artistId).setData(
        [
            "id" : artistId,
            "name" : userName,
            "avatarUrl" : urlS
        ]) { err in
            if let err = err {
                print("Error writting user document: \(err)")
            }else{
                print("User successfully added")
            }
        }
    }

    func getUsername(artist: String) async throws -> UserProfile {
        try await userCollection.document(artist).getDocument(as: UserProfile.self)
    }
    
    private let artCollection = Firestore.firestore().collection("arts")
  
    func getArtGallery(artworkId: String) async throws -> Artwork{
        try await artCollection.document(artworkId).getDocument(as: Artwork.self)
    }
    
    private func artDocument1(artwork: Artwork) -> DocumentReference {
        artCollection.document(artwork.id)
    }
    
    @Published private(set) var artGallery = [Artwork]()
    
    func getArtGalleries(artistId: String){
        db.collection("arts").whereField("artistID", isEqualTo: artistId).addSnapshotListener { querySnapshot, error in
            guard let documents = querySnapshot?.documents else{
                print("error fetching conversations: \(String(describing: error))")
                return
            }
            self.artGallery = documents.compactMap{ document -> Artwork? in
                do {
                    //print("ART: \(self.artGallery)")
                    return try document.data(as: Artwork.self)
                }catch{
                    print("Error decoding message document \(error)")
                    return nil
                }
            }
        }
    }
    @Published var arGalleries: [ArtGallery]?

    func getARGalleries(artistId: String) {
        db.collection("artGalleries").document(artistId).collection("galleries")
            .getDocuments { [weak self] (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                let profiles: [ArtGallery] = querySnapshot?.documents.compactMap {
                    try? $0.data(as: ArtGallery.self)
                } ?? []
                self?.arGalleries = profiles
                print("ARGALLERIS: \(String(describing: self?.arGalleries))")
            }
        }
    }

    func getAllArts() {
        db.collection("arts").addSnapshotListener { querySnapshot, error in
            guard let documents = querySnapshot?.documents else{
                print("error fetching conversations: \(String(describing: error))")
                return
            }
            self.artGallery = documents.compactMap{ document -> Artwork? in
                do {
                    return try document.data(as: Artwork.self)
                }catch{
                    print("Error decoding message document \(error)")
                    return nil
                }
            }
        }
    }
    
    private func artDocument() -> DocumentReference {
        artCollection.document()
    }
    
    var id1: String = ""
    
    func deleteArt(artwork: Artwork){
        db.collection("arts").document(artwork.id).delete() { err in
          if let err = err {
            print("Error deleting document \(err)")
          }
          else {
            print("Document deleted")
          }
        }
        deleteArtImage(artFile: artwork.artFile)
    }
    
    func deleteArtImage(artFile: String){
        let storageRef = storage.reference().child("\(MyKeys.imagesFolder)/\(artFile)")
        storageRef.delete{error in
            if error != nil{
                print("Deletion error")
            }
        }
        let thumbStorageRef = storage.reference().child("\(MyKeys.thumbnailFolder)/\(artFile)")
        thumbStorageRef.delete{error in
            if error != nil{
                print("Deletion error")
            }
        }
    }
    
    func updateAvatar(artistId: String, aImage: UIImage) async throws{
        let aImage = aImage
        print("Upload avatar")
        let uploadMetaData = StorageMetadata()
        uploadMetaData.contentType = "image/jpeg"
        let fileName = artistId
        let ref = FirebaseManager.shared.storage.reference().child(MyKeys.avatarFolder).child(fileName)
        let resizedAvatar = aImage.aspectFittedToHeight(50)
        guard let imageData = resizedAvatar.pngData() else { return }
        _ = ref.putData(imageData, metadata: uploadMetaData){metadata, err in
            if let err = err {
                print(err)
                return
            }
            ref.downloadURL{ [self]url, err in
                if let err = err {
                    print(err)
                    return
                }
                guard let url = url else{
                    print("error")
                    return
                }
                let urlString = url.absoluteString
                print("URLSTRING: ", urlString)
                urlS = urlString
                userCollection.document(artistId).updateData(
                [
                    "avatarUrl" : urlS
                ])
                { err in
                    
                    if let err = err {
                        print("Error writting user document: \(err)")
                    }else{
                        print("User successfully added")
                    }
                }
                uploaded = true
            }
        }
    }
    
    func updateUsername(artistId: String, username: String){
        userCollection.document(artistId).updateData(
        [
            "name" : username,
        ]) { err in
            if let err = err {
                print("Error writting user document: \(err)")
            }else{
                print("User successfully added")
            }
        }
    }
    
    func uploadAvatar(artistId: String, aImage: UIImage, username: String) async throws {
        let aImage = aImage
        print("Upload avatar")
        let uploadMetaData = StorageMetadata()
        uploadMetaData.contentType = "image/png"
        let fileName = artistId
        let ref = FirebaseManager.shared.storage.reference().child(MyKeys.avatarFolder).child(fileName)
        let resizedAvatar = aImage.aspectFittedToHeight(50)
        guard let imageData = resizedAvatar.pngData() else { return }
        _ = ref.putData(imageData, metadata: uploadMetaData){metadata, err in
            if let err = err {
                print(err)
                return
            }
            ref.downloadURL{ [self]url, err in
                if let err = err {
                    print(err)
                    return
                }
                guard let url = url else{
                    print("error")
                    return
                }
                let urlString = url.absoluteString
                print("URLSTRING: ", urlString)
                urlS = urlString
                uploadUser(artistId: artistId, userName: username)
            }
        }
    }
    
    func compressJpeg(image: UIImage) -> Data {
        let resizedImage = image.aspectFittedToHeight(200)
        return resizedImage.jpegData(compressionQuality: 0.2)!
    }
    
    func uploadGalleryPreview(id: String, _ image: UIImage, completion: @escaping (URL?) -> Void) {
        // Ensure you have a Firebase Storage reference
        let storageRef = Storage.storage().reference().child(MyKeys.galleryPreviewFolder).child(id)

        // Convert the image into Data
        if let imageData = image.jpegData(compressionQuality: 0.5) {

            // Define metadata
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"

            // Upload the image
            storageRef.putData(imageData, metadata: metadata) { (metadata, error) in
                if error == nil && metadata != nil {
                    // Retrieve the download URL
                    storageRef.downloadURL { (url, error) in
                        completion(url) // Return the download URL
                    }
                } else {
                    completion(nil)
                }
            }
        }
    }
    
    func uploadArt(artwork: Artwork, artistId: String, uImage: UIImage) async throws {
        var urlS1: String = ""
        var thumbUrlS1: String = ""
        let thumbUploadMetaData = StorageMetadata()
        thumbUploadMetaData.contentType = "image/jpeg"
        let filename = UUID().uuidString
        let thumbRef = FirebaseManager.shared.storage.reference().child(MyKeys.thumbnailFolder).child(filename)
        let resizedArt = compressJpeg(image: uImage)
        _ = thumbRef.putData(resizedArt, metadata: thumbUploadMetaData) { metadata, error in
            if let error = error {
                print(error)
                return
            }
            thumbRef.downloadURL { [self]url, error in
                if let error = error {
                    print(error)
                    return
                }
                guard let url = url else{
                    print("error")
                    return
                }
                let urlString = url.absoluteString
                self.thumbUrlS = urlString
                thumbUrlS1 = urlString
            }
            let uploadMetaData = StorageMetadata()
            uploadMetaData.contentType = "image/jpeg"
            let ref = FirebaseManager.shared.storage.reference().child(MyKeys.imagesFolder).child(filename)
            guard let imageData = uImage.jpegData(compressionQuality: 0.5) else { return }
            _ = ref.putData(imageData, metadata: uploadMetaData){metadata, err in
                if let err = err {
                    print(err)
                    return
                }
                ref.downloadURL{ [self]url, err in
                    if let err = err {
                        print(err)
                        return
                    }
                    guard let url = url else{
                        print("error")
                        return
                    }
                    let urlString = url.absoluteString
                    self.urlS = urlString
                    urlS1 = urlString
                    var artwork = artwork
                    let reference = self.artDocument()
                    self.updated = false
                    artwork.id = reference.documentID
                    artwork.artistID = artistId
                    artwork.image = urlS1
                    artwork.thumb = thumbUrlS1
                    artwork.artFile = filename
                    do{
                        try reference.setData(from: artwork, merge: false)
                        self.updated = true
                        print("updated: ", updated)
                    }
                    catch{
                    }
                }
            }
            
        }
    }
}

extension UIImage {
    func aspectFittedToHeight(_ newHeight: CGFloat) -> UIImage {
        let scale = newHeight / self.size.height
        let newWidth = self.size.width * scale
        let newSize = CGSize(width: newWidth, height: newHeight)
        let renderer = UIGraphicsImageRenderer(size: newSize)

        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}

extension Query {
    func getDocuments<T>(as type: T.Type) async throws -> [T] where T: Decodable {
        let snapshot = try await self.getDocuments()
        
        return try snapshot.documents.map({document in
            try document.data(as: T.self)
        })
    }
}

extension ArtGallery {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        galleryId = try container.decode(String.self, forKey: .galleryId)
        galleryName = try container.decode(String.self, forKey: .galleryName)
        galleryDescription = try container.decode(String.self, forKey: .galleryDescription)
        galleryImage = try container.decode(String.self, forKey: .galleryImage)

        coordinates = try container.decode([Double].self, forKey: .coordinates)
        
        let name = try container.decode([String].self, forKey: .name)
        let id = try container.decode([String].self, forKey: .id)
        let positionX = try container.decode([Float].self, forKey: .positionX)
        let positionY = try container.decode([Float].self, forKey: .positionY)
        let positionZ = try container.decode([Float].self, forKey: .positionZ)
        let nodeX = try container.decode([Float].self, forKey: .nodeX)
        let nodeY = try container.decode([Float].self, forKey: .nodeY)
        let nodeZ = try container.decode([Float].self, forKey: .nodeZ)
        let extentX = try container.decode([Float].self, forKey: .extentX)
        
        var nodePositions: [NodeData] = []
        
        for (index, name) in name.enumerated() {
            let id = id[index]
            let positionX = positionX[index]
            let positionY = positionY[index]
            let positionZ = positionZ[index]
            let nodeX = nodeX[index]
            let nodeY = nodeY[index]
            let nodeZ = nodeZ[index]
            let extentX = extentX[index]
            let nodePosition = NodeData(name: name, id: id, positionX: positionX, positionY: positionY, positionZ: positionZ, nodeX: nodeX, nodeY: nodeY, nodeZ: nodeZ, extentX: extentX)
            nodePositions.append(nodePosition)
        }
        self.nodePosition = nodePositions
    }
    
    enum CodingKeys: String, CodingKey {
        case galleryId, galleryName, galleryDescription, galleryImage, nodePosition, coordinates, name, id, positionX, positionY, positionZ, nodeX, nodeY, nodeZ, extentX
    }
}
