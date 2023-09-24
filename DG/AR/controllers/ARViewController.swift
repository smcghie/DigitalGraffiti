//
//  ViewController.swift
//  ArtGallery
//
//  Created by Scott McGhie on 2021-11-19.
//

import UIKit
import ARKit
import SwiftUI

class ARViewController: UIViewController, ARSCNViewDelegate, ObservableObject{
    
    @IBOutlet weak var toDisplay: UIButton!
    @IBOutlet weak var resetB: UIButton!
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var imageV: UIImageView!
    @IBOutlet weak var imgPrev: UIImageView!
    @IBOutlet weak var aName: UILabel!
    @IBOutlet weak var aArt: UILabel!
       
    var anchorArray: [ARPlaneAnchor] = []
    var activeNode: SCNNode?
    var hitNodeZ: CGFloat!
    var hitNodeCoord: SCNVector3!
    var hitNode: SCNNode!
    let configuration = ARWorldTrackingConfiguration()
    var node: SCNNode!
    var planeAnchor: ARPlaneAnchor!
    let omniNode = SCNNode()
    var image: UIImage?
    var artwork: Artwork?
    var aNode = SCNNode()
    var nodeCount = 0
    let coachingOverlay = ARCoachingOverlayView()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configuration.planeDetection = .vertical
        self.sceneView.session.run(configuration)
        self.sceneView.delegate = self
        self.configuration.isLightEstimationEnabled = true
        setupCoachingOverlay()
        coachingOverlay.setActive(true, animated: true)
        if anchorArray.isEmpty == true{
            imageV.image = UIImage(named: "xhair")
        }
        let urlString = artwork!.image
        let url = NSURL(string: urlString)! as URL
        if let imageData: NSData = NSData(contentsOf: url) {
            image = UIImage(data: imageData as Data)
        }
        imgPrev.image = image?.resized(to: CGSize(width:150, height:150))
        aName.text = artwork?.artist
        aArt.text = artwork?.name
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(pan(panGesture:)))
        self.sceneView.addGestureRecognizer(panRecognizer)
        let pinchRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(pinch))
        self.sceneView.addGestureRecognizer(pinchRecognizer)
        
        let resetImg = UIImage(named: "reset")?.resized(to: CGSize(width:45, height:45))
        resetB.setImage(resetImg?.withRenderingMode(.alwaysTemplate), for: .normal)
        resetB.tintColor = .white
        
        let toDisplayImg = UIImage(named: "hang")?.resized(to: CGSize(width:45, height:45))
        toDisplay.setImage(toDisplayImg?.withRenderingMode(.alwaysTemplate), for: .normal)
        toDisplay.tintColor = .white
        
    }
    
    @IBAction func toDisplay(_ sender: Any) {
        if !anchorArray.isEmpty{
            node = activeNode
            let lastAnchor = anchorArray.last!
            aNode = augmentArt(planeAnchor: lastAnchor)
            if node.childNodes.count < 2 {
                nodeCount += 1
                node!.addChildNode(aNode)
                print(aNode.name!)
                sceneView.scene.rootNode.addChildNode(self.omniNode)
            }
            imageV.isHidden = true
        }
    }
    
    @IBAction func resetB(_ sender: Any) {
        coachingOverlay.setActive(true, animated: true)
        let config = ARWorldTrackingConfiguration()
        config.isLightEstimationEnabled = true
        anchorArray.removeAll()
        imageV.image = UIImage(named: "xhair")
        imageV.isHidden = false
        node?.enumerateChildNodes { (node, stop) in
            node.removeFromParentNode()
        }
        self.configuration.planeDetection = .vertical
        sceneView.session.run(config, options: [.removeExistingAnchors, .resetTracking])
        self.sceneView.session.run(configuration)
        planeAnchor = nil
        nodeCount = 0
    }

    func augmentArt(planeAnchor: ARPlaneAnchor) -> SCNNode {
        let cImage = image
        let imageHRatio = cImage!.size.height / cImage!.size.width
        let artNode = SCNNode(geometry: SCNPlane(width: CGFloat(planeAnchor.extent.x), height: (CGFloat(planeAnchor.extent.x) * imageHRatio)))
        artNode.name = String("node" + String(nodeCount))
        artNode.geometry?.firstMaterial?.diffuse.contents = cImage
        artNode.geometry?.firstMaterial?.lightingModel = .lambert
        artNode.position = SCNVector3(planeAnchor.center.x, planeAnchor.center.y,planeAnchor.center.z)
        artNode.eulerAngles = SCNVector3(90.degToRad, -180.degToRad, 180.degToRad)
        return artNode
    }

    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if planeAnchor == nil {
            planeAnchor = anchor as? ARPlaneAnchor
            anchorArray.append(planeAnchor)
            activeNode = node
            DispatchQueue.main.async{
                self.imageV.image = UIImage(named: "check")
                self.coachingOverlay.setActive(false, animated: false)
            }
        }else{
                planeAnchor = anchor as? ARPlaneAnchor
                node.addChildNode(aNode)
                sceneView.scene.rootNode.addChildNode(self.omniNode)
            print("Vertical plane detected, ARPlaneAnchor created")
        }
    }

    @objc func pan(panGesture: UIPanGestureRecognizer){
        let sceneView = panGesture.view as! ARSCNView
        let panLocation = panGesture.location(in: self.sceneView)
        if imageV.isHidden {
            switch panGesture.state{
                case .began:
                    let hitTest = sceneView.hitTest(panLocation)
                    if !hitTest.isEmpty{
                        let hitNodeResult = hitTest.first!
                        hitNode = hitNodeResult.node
                        hitNodeCoord = hitNodeResult.worldCoordinates
                        hitNodeZ = CGFloat(sceneView.projectPoint(hitNodeCoord).z)
                    }
                case .changed:
                    let newRealPosition = sceneView.unprojectPoint(SCNVector3(panLocation.x, panLocation.y, hitNodeZ!))
                    let panVector = SCNVector3(
                        newRealPosition.x - hitNodeCoord!.x,
                        newRealPosition.y - hitNodeCoord!.y,
                        newRealPosition.z - hitNodeCoord!.z)
                        hitNode.localTranslate(by:panVector)
                        self.hitNodeCoord = newRealPosition
            default:
                break
            }
        }
    }
    
    @objc func pinch(pinchGesture: UIPinchGestureRecognizer){
        let sceneView = pinchGesture.view as! ARSCNView
        let pinchLocation = pinchGesture.location(in: sceneView)
        let hitTest = sceneView.hitTest(pinchLocation)
        if !hitTest.isEmpty {
            let hitNodeResult = hitTest.first!
            let node = hitNodeResult.node
            let pinchAction = SCNAction.scale(by: pinchGesture.scale, duration: 0)
            node.runAction(pinchAction)
            pinchGesture.scale = 1.0
        }
    }
}

extension UIImage {
    func resized(to size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}

extension Int {
    var degToRad: Double { return Double(self) * .pi/180 }
}

extension ARViewController {
    func renderer(_ renderer: SCNSceneRenderer,
           updateAtTime time: TimeInterval) {
        guard let lightEstimate = sceneView.session.currentFrame?.lightEstimate else { return }
        self.omniNode.light = SCNLight()
        self.omniNode.light?.type = .omni
        self.omniNode.light?.intensity = lightEstimate.ambientIntensity * 0.80
        self.omniNode.light?.temperature = lightEstimate.ambientColorTemperature
    }
}

extension ARViewController: ARCoachingOverlayViewDelegate {
    func setupCoachingOverlay() {
        coachingOverlay.session = self.sceneView.session
        coachingOverlay.delegate = self
        coachingOverlay.translatesAutoresizingMaskIntoConstraints = false
        self.sceneView.addSubview(coachingOverlay)
        NSLayoutConstraint.activate([
            coachingOverlay.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            coachingOverlay.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            coachingOverlay.widthAnchor.constraint(equalTo: view.widthAnchor),
            coachingOverlay.heightAnchor.constraint(equalTo: view.heightAnchor)
            ])
        coachingOverlay.activatesAutomatically = false
        coachingOverlay.goal = .verticalPlane
    }
}
