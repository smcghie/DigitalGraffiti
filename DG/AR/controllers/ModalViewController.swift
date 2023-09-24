//
//  ModalViewController.swift
//  DG
//
//  Created by Scott McGhie on 2023-09-01.
//

import Foundation
import UIKit

class ModalViewController: UIViewController, UITextFieldDelegate {
    weak var delegate: ModalViewControllerDelegate?
    @IBOutlet weak var snapshotImage: UIImageView!
    @IBOutlet weak var saveGallery: UIButton!
    var receivedData: UIImage?
    
    @IBOutlet weak var galleryName: UITextField!
    @IBOutlet weak var galleryDescription: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        galleryName.delegate = self
        galleryDescription.delegate = self
        //view.backgroundColor = .white
        
//        let dismissButton = UIButton(type: .system)
//        dismissButton.setTitle("Dismiss", for: .normal)
//        dismissButton.addTarget(self, action: #selector(dismissTapped), for: .touchUpInside)
//
//        view.addSubview(dismissButton)
//        dismissButton.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            dismissButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            dismissButton.centerYAnchor.constraint(equalTo: view.centerYAnchor)
//        ])
        //snapshotImage.image = receivedData
        loadSnap()
    }
    
    func loadSnap() {
        print("RECEIVED: \(receivedData)")
        //snapshotImage.contentMode = .scaleToFill
        snapshotImage.image = receivedData
    }
    
    @IBAction func saveGallery(_ sender: Any) {
        delegate?.sendDataBack(galleryName: galleryName.text!, galleryDescription: galleryDescription.text!)
        
        
        
        dismiss(animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()  // This makes the keyboard dismiss.
        return true
    }
//    @IBAction func saveGallery(_ button: UIButton) {
//        delegate?.sendDataBack(galleryName: galleryName.text!, galleryDescription: galleryDescription.text!)
//
//
//
//        dismiss(animated: true, completion: nil)
//    }
    
    
//    @objc func dismissTapped() {
//        dismiss(animated: true, completion: nil)
//    }
}
protocol ModalViewControllerDelegate: AnyObject {
    func sendDataBack(galleryName: String, galleryDescription: String)
}


