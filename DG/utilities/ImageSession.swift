//
//  ImageSession.swift
//  DG
//
//  Created by Scott McGhie on 2023-07-31.
//

import Foundation
import UIKit

class ImageSession: ObservableObject {
    
    let url: String?
    
    @Published var image: UIImage?
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false
    
    init(url: String?) {
        self.url = url
    }
    
    func fetch(){
        guard let url = url, let fetchURL = URL(string: url) else{
            print("URL ERROR")
            return
        }

        let request = URLRequest(url: fetchURL, cachePolicy: .returnCacheDataElseLoad)
        let task = URLSession.shared.dataTask(with: request) { [weak self] (data, response, error) in
            DispatchQueue.main.async{
                if let data = data, let image = UIImage(data: data){
                    self?.image = image
                }
            }
        }
        task.resume()
    }
}
