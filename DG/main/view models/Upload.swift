//
//  Upload.swift
//  DigitalGratiffi
//
//  Created by Scott McGhie on 2022-11-27.
//

import Foundation
import Firebase
import FirebaseFirestore

class Upload {
    let db = Firestore.firestore()
    func uploadGallery(aG: ArtGallery, id: String){
        
        var name: [String] = []
        var aGId: [String] = []
        var positionX: [Float] = []
        var positionY: [Float] = []
        var positionZ: [Float] = []
        var nodeX: [Float] = []
        var nodeY: [Float] = []
        var nodeZ: [Float] = []
        var extentX: [Float] = []
        var coordinates: [Double] = []
        for node in aG.nodePosition{
            name.append(node.name)
            aGId.append(node.id)
            positionX.append(node.positionX)
            positionY.append(node.positionY)
            positionZ.append(node.positionZ)
            nodeX.append(node.nodeX)
            nodeY.append(node.nodeY)
            nodeZ.append(node.nodeZ)
            extentX.append(node.extentX)
        }
        
        for coord in aG.coordinates{
            coordinates.append(coord)
        }
                
        db.collection("artGalleries").document("\(aG.galleryId)/galleries/\(id)").setData([
            "galleryId": id,
            "galleryName": aG.galleryName,
            "galleryDescription": aG.galleryDescription,
            "galleryImage": aG.galleryImage,
            "name": name,
            "id": aGId,
            "positionX": positionX,
            "positionY": positionY,
            "positionZ": positionZ,
            "nodeX": nodeX,
            "nodeY": nodeY,
            "nodeZ": nodeZ,
            "extentX": extentX,
            "coordinates": coordinates]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
    }
}
