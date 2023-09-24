//
//  ViewController.swift
//  DG
//
//  Created by Scott McGhie on 2021-11-19.
//

import ARKit
import SwiftUI
import FirebaseCore
import FirebaseStorage
import MapKit
import CoreLocation

class AGViewController: UIViewController, ARSCNViewDelegate, ObservableObject, CLLocationManagerDelegate{
    
    @IBOutlet weak var toDisplay: UIButton!
    @IBOutlet weak var resetB: UIButton!
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var imageV: UIImageView!
    @IBOutlet weak var aName: UILabel!
    @IBOutlet weak var aArt: UILabel!
    @IBOutlet weak var savePosition: UIButton!
    @IBOutlet weak var loadPosition: UIButton!
    @IBOutlet weak var prevB: UIButton!
    @IBOutlet weak var nextB: UIButton!
    @IBOutlet weak var marketDetail: UIButton!
    
    var statusComplete: Bool = false
    var nodePosition: [NodeData] = []
    var coordinates: [Double] = []
    var anchorArray: [ARPlaneAnchor] = []
    var activeNode: SCNNode?
    var hitNodeZ: CGFloat!
    var hitNodeCoord: SCNVector3!
    var hitNode: SCNNode!
    var hitNode1: SCNNode!
    let configuration = ARWorldTrackingConfiguration()
    var node: SCNNode!
    var planeAnchor: ARPlaneAnchor!
    let omniNode = SCNNode()
    var image: UIImage?
    var aNode = SCNNode()
    var extentX: Float!
    var toDisplayCount = 0
    var currentA: Int = 0
    var nodeIds: [String] = []
    var artGalleries: [ArtGallery] = []
    var checkpoint: Bool = false
    var artwork: Artwork?
    var userId: String?
    var nodeCounter: Int = 0
    var currentNode: Int = 0
    var upload = Upload()
    @ObservedObject var queryArt = QueryArt()
    let coachingOverlay = ARCoachingOverlayView()
    @State private var locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCoachingOverlay()
        locationManager.requestWhenInUseAuthorization()

        coachingOverlay.setActive(true, animated: true)
        self.configuration.planeDetection = .vertical
        self.sceneView.session.run(configuration)
        self.configuration.isLightEstimationEnabled = true
        for i in 0..<queryArt.artGallery.count{
            if artwork?.id == queryArt.artGallery[i].id {
                currentA = i
            }
        }

//        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
        
        aName.text = queryArt.artGallery[currentA].artist
        aArt.text = queryArt.artGallery[currentA].name
        retImage(node: currentA)
        currentNode = currentA
        
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(pan(panGesture:)))
        self.sceneView.addGestureRecognizer(panRecognizer)
        let pinchRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(pinch))
        self.sceneView.addGestureRecognizer(pinchRecognizer)
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tap))
        self.sceneView.addGestureRecognizer(tapRecognizer)
        
        let resetImg = UIImage(named: "reset")?.resized(to: CGSize(width:40, height:40))
        resetB.setImage(resetImg?.withRenderingMode(.alwaysTemplate), for: .normal)
        resetB.tintColor = .white
        
        let toDisplayImg = UIImage(named: "hang")?.resized(to: CGSize(width:40, height:40))
        toDisplay.setImage(toDisplayImg?.withRenderingMode(.alwaysTemplate), for: .normal)
        toDisplay.tintColor = .white
        
        let saveImg = UIImage(named: "save")?.resized(to: CGSize(width:35, height:35))
        savePosition.setImage(saveImg?.withRenderingMode(.alwaysTemplate), for: .normal)
        savePosition.tintColor = .white
        
        let dlImg = UIImage(named: "download")?.resized(to: CGSize(width:35, height:35))
        loadPosition.setImage(dlImg?.withRenderingMode(.alwaysTemplate), for: .normal)
        loadPosition.tintColor = .white
        
        let leftImg = UIImage(named: "left-chevron")?.resized(to: CGSize(width:40, height:40))
        prevB.setImage(leftImg?.withRenderingMode(.alwaysTemplate), for: .normal)
        prevB.tintColor = .white
        
        let rightImg = UIImage(named: "right-chevron")?.resized(to: CGSize(width:40, height:40))
        nextB.setImage(rightImg?.withRenderingMode(.alwaysTemplate), for: .normal)
        nextB.tintColor = .white
        
        if currentA < queryArt.artGallery.count-1{
            prevB.isEnabled = false
        }else{
            nextB.isEnabled = true
        }
        if currentA == queryArt.artGallery.count-1{
            prevB.isEnabled = false
            nextB.isEnabled = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.sceneView.session.pause()
        self.sceneView?.session.delegate = nil
        self.sceneView.scene = SCNScene()
        self.sceneView?.removeFromSuperview()
        self.sceneView?.window?.resignKey()
        self.sceneView = nil
    }
    
    func retImage(node: Int){
        let url = URL(string: queryArt.artGallery[node].image)!
        URLSession.shared.dataTask(with: url) { data, response, error in
                guard let data = data, error == nil else { return }
            DispatchQueue.main.async { [self] in
                    self.image = UIImage(data: data)
                    let imagePrev = self.image?.resized(to: CGSize(width:120, height:120))
                    marketDetail.setImage(imagePrev?.withRenderingMode(.alwaysOriginal), for: .normal)
                }
        }.resume()
    }
    
    @IBAction func prevB(_ sender: Any) {
        if currentA > 0{
            nextB.isEnabled = true
            currentA -= 1
            if currentA == 0{
                prevB.isEnabled = false
            }
        }else{
            prevB.isEnabled = false
        }
        updateMenu()
    }
    
    @IBAction func nextB(_ sender: Any) {
        if currentA < queryArt.artGallery.count-1{
            prevB.isEnabled = true
            currentA += 1
            if currentA == queryArt.artGallery.count-1{
                nextB.isEnabled = false
            }
        }
        else{
            nextB.isEnabled = false
        }
        updateMenu()
    }
    
    func updateMenu (){
        retImage(node: currentA)
        aName.text = queryArt.artGallery[currentA].artist
        aArt.text = queryArt.artGallery[currentA].name
    }

    @IBAction func resetB(_ sender: Any) {
        sceneView.session.pause()
        coachingOverlay.setActive(true, animated: true)
        let config = ARWorldTrackingConfiguration()
        nodePosition.removeAll()
        sceneView.scene.rootNode.enumerateChildNodes { (node, stop) in
            node.removeFromParentNode()
        }
        activeNode = nil
        config.planeDetection = .vertical
        sceneView.session.run(config, options: [.removeExistingAnchors, .resetTracking])

        if checkpoint == true {
            return
        }else{
            anchorArray.removeAll()
            planeAnchor = nil
        }
    }
    
    @IBAction func artDetail(_ sender: Any) {
        let art = queryArt.artGallery[currentNode]
        let hostingController = UIHostingController(rootView: ArtDetailsView(artwork: art))
        navigationController?.pushViewController(hostingController, animated: true)
    }
    
    var galleryName: String?
    var galleryDescription: String?
    var mapped: ARWorldMap?
    var snapImage: UIImage?
    
    @IBAction func savePosition(_ button: UIButton) {
        
        var locationM = locationManager.location?.coordinate
        if let result = locationM {
            print("location: \(result)")
            print("userId: \(userId!)")
            coordinates.removeAll()
            coordinates.append(result.latitude)
            coordinates.append(result.longitude)
        }
        sceneView.session.getCurrentWorldMap { [self] worldMap, error in
            mapped = worldMap
            guard let snapshotAnchor = SnapshotAnchor(capturing: self.sceneView)
                else { fatalError("Can't take snapshot") }
            mapped!.anchors.append(snapshotAnchor)
            snapImage = UIImage(data: snapshotAnchor.imageData)
            
            let desinationVC = self.storyboard?.instantiateViewController(withIdentifier: "ModalViewController") as! ModalViewController
            desinationVC.delegate = self
            desinationVC.receivedData = snapImage
            desinationVC.modalPresentationStyle = .pageSheet
            self.present(desinationVC, animated: true, completion: nil)
        }
    }
    
    var mapDataFromFile: Data? {
        return try? Data(contentsOf: mapSaveURL)
    }
    
    func downloadGallery(){
        print("load button pressed")
        let worldMap: ARWorldMap = {
            guard let data = mapDataFromFile
                else { fatalError("Map data doesn't exist") }
            do {
                guard let worldMap = try NSKeyedUnarchiver.unarchivedObject(ofClass: ARWorldMap.self, from: data)
                    else { fatalError("No ARWorldMap in archive.") }
                return worldMap
            } catch {
                fatalError("Can't unarchive ARWorldMap from file data: \(error)")
            }
        }()
        nodePosition = dlNodePosition
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        let configuration = self.configuration
        
        configuration.initialWorldMap = worldMap

        imageV.isHidden = true
        nodeIds.removeAll()
        for i in nodePosition {
            nodeIds.append(i.id)
        }
        nodeIds.reverse()
        DispatchQueue.main.async{
            self.queryArt.getArtGallery(nodeIds: self.nodeIds)
            galleryCards.sort(by: { $0.name > $1.name })
        }
    }
    
    @IBAction func loadPosition (_ button: UIButton) {
        print("load button pressed")
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let mapRef = storageRef.child("world.map")
        counter = 0
        nodeCounter = 0
        coachingOverlay.setActive(false, animated: false)
        queryArt.getArtGalleries()
        let localURL = mapSaveURL

        let downloadTask = mapRef.write(toFile: localURL, completion:  { url, error in
          if let error = error {
            print("Map download error", error)
          } else {
              DispatchQueue.main.async {
                  self.downloadGallery()
              }
          }
        })
        downloadTask.observe(.progress) { snap in
          let perComplete = 100.0 * Double(snap.progress!.completedUnitCount)
            / Double(snap.progress!.totalUnitCount)
//        print("% complete: ", perComplete)
//            self.statusComplete = true
            if perComplete == 100.0{
                print("DOWNLOADCOMPLETE")
                self.statusComplete = true
            }
        }
        checkpoint = true
    }
    
    @IBAction func toDisplay(_ sender: Any) {
        guard let frame = sceneView.session.currentFrame else { return }
        print("WM STATUS: \(frame.worldMappingStatus)")
        if !anchorArray.isEmpty{
            node = activeNode
            let name = UUID().uuidString
            let lastAnchor = anchorArray.last!
            aNode = augmentArt(planeAnchor: lastAnchor, name: name)

            if node.childNodes.count < 20 {
                node!.addChildNode(aNode)
                sceneView.scene.rootNode.addChildNode(self.omniNode)
            }
            let id = queryArt.artGallery[currentA].id
            let positionX = node.worldPosition.x
            let positionY = node.worldPosition.y
            let positionZ = node.worldPosition.z
            let nodeW = node.scale.x
            let nodeH = node.scale.y
            let nodeZ = node.scale.z
            if toDisplayCount < 1{
                extentX = planeAnchor.planeExtent.width
            }
            toDisplayCount += 1

            let nodeP = NodeData(name: name, id: id, positionX: positionX, positionY: positionY, positionZ: positionZ, nodeX: nodeW, nodeY: nodeH, nodeZ: nodeZ, extentX: extentX)

            nodePosition.append(nodeP)
            imageV.isHidden = true
            print("display button pressed")
        }
    }
    
    func augmentArt(planeAnchor: ARPlaneAnchor, name: String) -> SCNNode {
        let cImage = image
        let imageHRatio = cImage!.size.height / cImage!.size.width
        var artNode = SCNNode()
        if nodePosition.isEmpty{
            artNode = SCNNode(geometry: SCNPlane(width: CGFloat(planeAnchor.planeExtent.width), height: (CGFloat(planeAnchor.planeExtent.width) * imageHRatio)))
        }else{
            artNode = SCNNode(geometry: SCNPlane(width: CGFloat(nodePosition[0].extentX), height: (CGFloat(nodePosition[0].extentX) * imageHRatio)))
        }
        artNode.name = name
        artNode.geometry?.firstMaterial?.diffuse.contents = cImage
        artNode.geometry?.firstMaterial?.lightingModel = .lambert
        artNode.position = SCNVector3(planeAnchor.center.x, planeAnchor.center.y,planeAnchor.center.z)
        artNode.eulerAngles = SCNVector3(90.degToRad, -180.degToRad, 180.degToRad)
        nodeCounter += 1
        return artNode
    }
    
    func augmentArt1(planeAnchor: ARPlaneAnchor, nodes: NodeData ) -> SCNNode {
        let index = galleryCards.firstIndex { $0.id == nodes.id }

        let urlString = galleryCards[index!].image
        let url = NSURL(string: urlString)! as URL
        if let imageData: NSData = NSData(contentsOf: url) {
            image = UIImage(data: imageData as Data)
        }
        let cImage = image
        let imageHRatio = cImage!.size.height / cImage!.size.width
        var artNode = SCNNode()
        artNode = SCNNode(geometry: SCNPlane(width: CGFloat(nodes.extentX), height: (CGFloat(nodes.extentX) * imageHRatio)))
        artNode.name = nodes.name
        artNode.geometry?.firstMaterial?.diffuse.contents = cImage
        artNode.geometry?.firstMaterial?.lightingModel = .lambert
        artNode.position = SCNVector3(planeAnchor.center.x, planeAnchor.center.y,planeAnchor.center.z)
        artNode.eulerAngles = SCNVector3(90.degToRad, -180.degToRad, 180.degToRad)
        nodeCounter += 1
        return artNode
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if anchorArray.isEmpty {
            guard nodePosition.isEmpty
                else { return }
            planeAnchor = anchor as? ARPlaneAnchor
            anchorArray.append(planeAnchor)
            activeNode = node
            DispatchQueue.main.async{
                self.coachingOverlay.setActive(false, animated: false)
            }
            checkpoint = false
        }else {
            guard checkpoint == true
                else { return }
            for nodes in nodePosition {
                planeAnchor = anchor as? ARPlaneAnchor
                activeNode = node
                aNode = augmentArt1(planeAnchor: planeAnchor!, nodes: nodes)
                aNode.position.x = nodes.positionX
                aNode.position.y = nodes.positionY
                aNode.position.z = nodes.positionZ
                aNode.scale.x = nodes.nodeX
                aNode.scale.y = nodes.nodeY
                aNode.scale.z = nodes.nodeZ
                activeNode!.addChildNode(aNode)
                //sceneView.scene.rootNode.addChildNode(aNode)
                sceneView.scene.rootNode.addChildNode(self.omniNode)
                print("Vertical plane detected, ARPlaneAnchor created")
            }
            checkpoint = false
        }
    }
    
    lazy var mapSaveURL: URL = {
        do {
            return try FileManager.default
                .url(for: .documentDirectory,
                     in: .userDomainMask,
                     appropriateFor: nil,
                     create: true)
                .appendingPathComponent("world.map")
        } catch {
            fatalError("Can't get map file save URL: \(error.localizedDescription)")
        }
    }()

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
                if hitNode.name != nil {
                    let hitNodeName = hitNode.name!
                    let index = nodePosition.firstIndex { $0.name == hitNodeName }
                    if !(index == nil) {
                        nodePosition[index!].positionX = hitNode.position.x
                        nodePosition[index!].positionY = hitNode.position.y
                        nodePosition[index!].positionZ = hitNode.position.z
                    }
                }
            default:
                break
            }
        }
    }
    
    @objc func tap(tapGesture: UITapGestureRecognizer){
        let sceneView = tapGesture.view as! ARSCNView
        let tapLocation = tapGesture.location(in: sceneView)
        let hitTest = sceneView.hitTest(tapLocation)
        guard let hitNodeResult = hitTest.first
            else{return}
        hitNode = hitNodeResult.node
        if hitNode.name != nil {
        let hitNodeName = hitNode.name!
            DispatchQueue.main.async { [self] in
                let name = self.nodePosition.firstIndex { $0.name == hitNodeName }
                let artId = self.nodePosition[name!].id
                let index = queryArt.artGallery.firstIndex { $0.id == artId }
                self.retImage(node: index!)
                self.aName.text = queryArt.artGallery[index!].artist
                self.aArt.text = queryArt.artGallery[index!].name
                self.currentNode = index!
            }
        }
    }
    
    @objc func pinch(pinchGesture: UIPinchGestureRecognizer){
        let sceneView = pinchGesture.view as! ARSCNView
        let pinchLocation = pinchGesture.location(in: sceneView)
        let hitTest = sceneView.hitTest(pinchLocation)
        if !hitTest.isEmpty {
            let hitNodeResult = hitTest.first!
            hitNode1 = hitNodeResult.node
            let pinchAction = SCNAction.scale(by: pinchGesture.scale, duration: 0)
            hitNode1.runAction(pinchAction)
            pinchGesture.scale = 1.0
            if hitNode1.name != nil{
                let hitNodeName = hitNode1.name!
                
                let index = nodePosition.firstIndex { $0.name == hitNodeName }
                if !(index == nil){
                    nodePosition[index!].nodeX = hitNode1.scale.x
                    nodePosition[index!].nodeY = hitNode1.scale.y
                    nodePosition[index!].nodeZ = hitNode1.scale.z
                }
            }
        }
    }
}

extension AGViewController: ARCoachingOverlayViewDelegate {
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

extension AGViewController {
    func renderer(_ renderer: SCNSceneRenderer,
           updateAtTime time: TimeInterval) {
        guard let lightEstimate = sceneView.session.currentFrame?.lightEstimate else { return }
        self.omniNode.light = SCNLight()
        self.omniNode.light?.type = .omni
        self.omniNode.light?.intensity = lightEstimate.ambientIntensity * 0.80
        self.omniNode.light?.temperature = lightEstimate.ambientColorTemperature
        
    }
}

extension AGViewController: ModalViewControllerDelegate {
    func sendDataBack(galleryName: String, galleryDescription: String) {
        self.galleryName = galleryName
        self.galleryDescription = galleryDescription
        let uuid = UUID().uuidString
        if let image = snapImage {
            queryArt.uploadGalleryPreview(id: uuid, image) { [self] (downloadURL) in
                if let url = downloadURL {
                    print("Image uploaded successfully: \(url)")
                    do {
                        let data = try NSKeyedArchiver.archivedData(withRootObject: mapped!, requiringSecureCoding: true)
                        let storage = Storage.storage()
                        let storageRef = storage.reference()
                        let mapRef = storageRef.child("galleryFolder/\(uuid)")
                        let uploadTask = mapRef.putData(data, metadata: nil) { (metadata, error) in
                          guard let metadata = metadata else {
                            return
                          }
                          mapRef.downloadURL { (url, error) in
                            guard let downloadURL = url else {
                              return
                            }
                          }
                        }
                    } catch {
                        fatalError("Can't save map: \(error.localizedDescription)")
                    }
                    print("save button pressed")
                    print("NAME: \(galleryName)")
                    print("NAME: \(galleryDescription)")

                    let artGallery = ArtGallery(galleryId: userId!, galleryName: galleryName, galleryDescription: galleryDescription, galleryImage: url.absoluteString, nodePosition: nodePosition, coordinates: coordinates)
                    artGalleries.append(artGallery)
                    upload.uploadGallery(aG: artGallery, id: uuid)
                } else {
                    print("Error uploading image.")
                }
            }
        }

    }
}

