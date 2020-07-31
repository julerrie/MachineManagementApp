//
//  ARViewController.swift
//  MachineManagment
//
//  Created by julerrie on 2020/05/07.
//  Copyright © 2020 julerrie. All rights reserved.
//

import ARKit
import UIKit
import os.signpost



//reference: https://www.appcoda.com/arkit-persistence/

protocol ARViewPresentDelegate {
    func setMessage(text: String)
    func setButtonAvaliable(avaliable: Bool)
}

class ARViewController: UIViewController, ObservableObject {
    
    var sceneView: ARSCNView = ARSCNView()
    var arViewPresentDelegate: ARViewPresentDelegate?
    let selectView: SelectView = SelectView(frame: CGRect(x: 0, y: 0, width: 300, height: 400))
    let settingView: SettingView = SettingView(frame: CGRect(x: 0, y: 0, width: 300, height: 200))
    var deviceID: String = ""
    var location: CGPoint = CGPoint()
    var worldString: String = ""
    var lastUpdateTime: TimeInterval = TimeInterval()
    //機器情報リスト
    var machineList: [String:MachineModel] = [:]
    //機器位置リスト(node)
    var nodeList: [String: SCNNode] = [:]
    var nodeButton: [String: DirectionView] = [:]
    //機器位置リスト(anchor)
    var tempAnchorList: [String:ARAnchor] = [:]
    var tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer()
    
    public func initProcess() {
        super.viewDidLoad()
        sceneView = ARSCNView(frame: UIScreen.main.bounds)
        self.sceneView.delegate = self
        view.addSubview(sceneView)
        selectView.center = self.view.center
        selectView.center.y -= 100
        selectView.layer.cornerRadius = 10
        selectView.deviceIdSelected = { result in
            self.updateNodePosition(result: result)
        }
        selectView.worldMapSelected = { worldMap in
            self.worldString = worldMap
            self.loadingProcess()
            self.tapGestureRecognizer.isEnabled = true
        }
        selectView.closeView = {
            self.arViewPresentDelegate?.setButtonAvaliable(avaliable: true)
            self.tapGestureRecognizer.isEnabled = true
        }
        settingView.center = self.view.center
        settingView.center.y -= 100
        settingView.layer.cornerRadius = 10
        settingView.setWorldMapNamp = { result in
            self.worldString = result
            self.saveProcess()
        }
        settingView.closeView = {
            self.tapGestureRecognizer.isEnabled = true
            self.arViewPresentDelegate?.setButtonAvaliable(avaliable: true)
        }
        self.addTapGestureToSceneView()
        self.configureLighting()
        self.loadBarButtonItemDidTouch()
    }
    
    public func cleanProcess() {
        self.selectView.removeFromSuperview()
        self.settingView.removeFromSuperview()
        self.sceneView.removeFromSuperview()
        self.sceneView.session.pause()
    }
    
    private func saveProcess() {
        sceneView.session.getCurrentWorldMap { (worldMap, error) in
            guard let worldMap = worldMap else {
                self.showAlertMessage(message: "Error getting current world map.")
                return
            }
            
            do {
                for (key, device) in self.tempAnchorList {
                    DBManager.sharedInstance.saveDeviceAnchor(id: key, worldMap: self.worldString, anchor: device.transform)
                }
                try self.archive(worldMap: worldMap)
                DispatchQueue.main.async {
                    self.arViewPresentDelegate?.setMessage(text: "World map is saved.")
                    DBManager.sharedInstance.saveWorldMapModel( path: self.worldString)
                    self.showAlertMessage(message: "デバイス位置を保存しました。")
                    self.tapGestureRecognizer.isEnabled = true
                    self.arViewPresentDelegate?.setButtonAvaliable(avaliable: true)
                }
            } catch {
                self.showAlertMessage(message: "Error saving world map: \(error.localizedDescription)")
            }
        }
    }
    
    func configureLighting() {
        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true
    }
    
    func addTapGestureToSceneView() {
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didReceiveTapGesture(_:)))
        sceneView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    //アラートメッセージを表示
    func showAlertMessage(message: String) {
        let alertView: UIAlertController = UIAlertController(title: "", message: message, preferredStyle: .alert)
        let okAction: UIAlertAction = UIAlertAction(title: "確認", style: .default) { _ in
            self.selectView.removeFromSuperview()
            self.settingView.removeFromSuperview()
        }
        alertView.addAction(okAction)
        self.present(alertView, animated: true, completion: nil)
    }
    
    func updateNodePosition(result: String) {
        self.deviceID = result
        guard let hitTestResult = self.sceneView.hitTest(self.location, types: [.featurePoint, .estimatedHorizontalPlane]).first
            else { return }
        //新しいanchor作成
        let anchor = ARAnchor(name: result, transform: hitTestResult.worldTransform)
        if let oldAnchor = self.tempAnchorList[self.deviceID] {
            self.sceneView.session.remove(anchor: oldAnchor)
            self.sceneView.scene.rootNode.enumerateChildNodes({ (childNode, _) in
                if childNode.name == result{
                    childNode.removeFromParentNode()
                }
            })
        }
        //新しいnode作成
        if !self.nodeList.keys.contains(result) {
            if let machine: MachineModel = self.machineList[result] {
                let rectangleNode = self.generateRectangleNode(displayMachine: machine)
                self.nodeList[result] = rectangleNode
            }
        }
        self.tempAnchorList[self.deviceID] = anchor
        self.sceneView.session.add(anchor: anchor)
    }
    
    //デバイス位置を設定
    @objc func didReceiveTapGesture(_ sender: UITapGestureRecognizer) {
        self.selectView.updateWith(selectDevice: true)
        self.view.addSubview(selectView)
        location = sender.location(in: sceneView)
        self.arViewPresentDelegate?.setButtonAvaliable(avaliable: false)
    }
    
    //デバイス位置を保存
    func saveBarButtonItemDidTouch() {
        if !self.worldString.isEmpty {
            self.saveProcess()
        } else {
            self.view.addSubview(settingView)
            self.tapGestureRecognizer.isEnabled = false
            self.arViewPresentDelegate?.setButtonAvaliable(avaliable: false)
        }
    }
    
    //デバイス位置を読み取り
    func loadBarButtonItemDidTouch() {
        self.selectView.updateWith(selectDevice: false)
        self.view.addSubview(self.selectView)
        self.tapGestureRecognizer.isEnabled = false
    }
    
    func loadingProcess() {
        do {
            let worldURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                .appendingPathComponent("worldMapURL_" + self.worldString)
            if let worldMapData = retrieveWorldMapData(from: worldURL),
                let worldMap = unarchive(worldMapData: worldMapData) {
                resetTrackingConfiguration(with: worldMap)
            } else {
                resetTrackingConfiguration()
            }
        } catch {
            //self.showAlertMessage(message: "Error retrieving world map data.")
            return
        }
        
        let newMachineList = DBManager.sharedInstance.getMachineList()
        for machine in newMachineList {
            let newMachine = MachineModel()
            newMachine.managementId = machine.managementId
            newMachine.group = machine.group
            newMachine.type = machine.type
            newMachine.userName = machine.userName
            self.machineList[machine.managementId] = newMachine
        }
        
        let anchorList = DBManager.sharedInstance.getDeviceAnchor()
        //初期化
        self.tempAnchorList = [:]
        for anchorModel in anchorList {
            if anchorModel.worldMap == self.worldString {
                var anchorMatrix: simd_float4x4 = simd_float4x4()
                if anchorModel.anchorList.count == 16{
                    anchorMatrix.columns.0 = simd_float4(arrayLiteral: anchorModel.anchorList[0],anchorModel.anchorList[1],anchorModel.anchorList[2],anchorModel.anchorList[3] )
                    anchorMatrix.columns.1 = simd_float4(arrayLiteral: anchorModel.anchorList[4],anchorModel.anchorList[5],anchorModel.anchorList[6],anchorModel.anchorList[7] )
                    anchorMatrix.columns.2 = simd_float4(arrayLiteral: anchorModel.anchorList[8],anchorModel.anchorList[9],anchorModel.anchorList[10],anchorModel.anchorList[11] )
                    anchorMatrix.columns.3 = simd_float4(arrayLiteral: anchorModel.anchorList[12],anchorModel.anchorList[13],anchorModel.anchorList[14],anchorModel.anchorList[15] )
                }
                let anchor = ARAnchor(name: anchorModel.managementId, transform: anchorMatrix)
                print(anchorModel.managementId)
                print(anchor.transform.columns.3.x,anchor.transform.columns.3.y, anchor.transform.columns.3.z)
                self.tempAnchorList[anchorModel.managementId] = anchor
                if let machine: MachineModel = self.machineList[anchorModel.managementId] {
                    let rectangleNode = self.generateRectangleNode(displayMachine: machine)
                    self.nodeList[anchorModel.managementId] = rectangleNode
                }
                sceneView.session.add(anchor: anchor)
            }
        }
    }
    
    func retrieveWorldMapData(from url: URL) -> Data? {
        do {
            let worldURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                .appendingPathComponent("worldMapURL_" + self.worldString)
            return try Data(contentsOf: worldURL)
        } catch {
            //self.showAlertMessage(message: "Error retrieving world map data.")
            return nil
        }
    }
    
    func archive(worldMap: ARWorldMap) throws {
        let worldURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("worldMapURL_" + self.worldString)
        worldMap.anchors = []
        for anchor in self.tempAnchorList {
            worldMap.anchors.append(anchor.value)
        }
        if FileManager.default.fileExists(atPath: worldURL.absoluteString) {
            print("update wolrdmap info")
            try FileManager.default.removeItem(atPath: worldURL.absoluteString)
        }
        let data = try NSKeyedArchiver.archivedData(withRootObject: worldMap, requiringSecureCoding: true)
        try data.write(to: worldURL, options: [.atomic])
    }
    
    func unarchive(worldMapData data: Data) -> ARWorldMap? {
        guard let unarchievedObject = try? NSKeyedUnarchiver.unarchivedObject(ofClass: ARWorldMap.self, from: data) else { return nil }
        let worldMap = unarchievedObject
        return worldMap
    }
    
    //初期化
    func resetTrackingConfiguration(with worldMap: ARWorldMap? = nil) {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]
        
        let options: ARSession.RunOptions = [.resetTracking, .removeExistingAnchors]
        self.tempAnchorList = [:]
        self.nodeList = [:]
        if let worldMap = worldMap {
            configuration.initialWorldMap = worldMap
            
            self.arViewPresentDelegate?.setMessage(text: "Found saved world map.")
        } else {
            self.arViewPresentDelegate?.setMessage(text: "Move camera around to map your surrounding space.")
        }
        
        sceneView.debugOptions = [.showFeaturePoints]
        sceneView.session.run(configuration, options: options)
        if !self.nodeButton.isEmpty{
            for button in self.nodeButton {
                DispatchQueue.main.async {
                    button.value.removeFromSuperview()
                }
            }
            self.nodeButton = [:]
        }
    }
    
}

extension ARViewController: ARSCNViewDelegate {
    
    //新しいnode追加
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard !(anchor is ARPlaneAnchor) else { return }
        var rectangleNode: SCNNode
        var message = ""
        for (key, value) in self.tempAnchorList {
            
            if value.name == anchor.name {
                message = key
                break
            }
        }
        print(message)
        if !message.isEmpty {
            //保存されてるノードを選択して画面に追加＆表示
            rectangleNode = self.nodeList[message] ?? SCNNode()
            DispatchQueue.main.async {
                node.addChildNode(rectangleNode)
                
            }
        }
        
    }
    
    //ナビゲーション位置更新
    public func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        let deltaTime = time - lastUpdateTime
        let screenWidth = self.view.frame.size.width
        let screenHeight = self.view.frame.size.height
        let logHandle = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "hoge")

        let spid = OSSignpostID(log: logHandle)
        os_signpost(.begin, log: logHandle, name: "Process A", signpostID: spid)
        if deltaTime>0.1{
            guard let pointOfView = renderer.pointOfView else {
                return
            }
            for node in self.nodeList {
                let isVisible = renderer.isNode(node.value, insideFrustumOf: pointOfView)
                let xDistance = node.value.convertPosition(node.value.position, to: pointOfView).x
                let yDistance = node.value.convertPosition(node.value.position, to: pointOfView).y
//                let zDistance = node.value.convertPosition(node.value.position, to: pointOfView).z
//                print(node.key)
//                print(xDistance, yDistance, zDistance)
                if !isVisible {
                    let xRange: Float = 0.2
                    let yRange: Float = 0.2
                    var xVal: CGFloat = 0.5 * screenWidth - 150
                    var yVal: CGFloat = 0.5 * screenHeight - 80
                    var direction: String = ""
                    
                    if abs(xDistance) >= xRange{
                        if xDistance >= 0 {
                            xVal = screenWidth - 150
                            direction = "arrow.right"
                        } else {
                            xVal = 0
                            direction = "arrow.left"
                        }
                        if yDistance <= 0 {
                            yVal += 0.5 * screenHeight * CGFloat(abs(yDistance) / yRange)
                            if yVal > screenHeight - 80 {
                                yVal = screenHeight - 80
                            }
                        } else {
                            yVal -= 0.5 * screenHeight * CGFloat(abs(yDistance) / yRange)
                            if yVal < 0 {
                                yVal = 0
                            }
                        }
                    } else {
                        if xDistance >= 0 {
                            xVal += 0.5 * screenWidth * CGFloat(abs(xDistance) / xRange)
                            if xVal > screenWidth - 150 {
                                xVal = screenWidth - 150
                            }
                        } else if xDistance < 0 {
                            xVal -= 0.5 * screenWidth * CGFloat(abs(xDistance) / xRange)
                            if xVal < 0 {
                                xVal = 0
                            }
                        }
                        if yDistance <= 0 {
                            yVal = screenHeight - 80
                            direction = "arrow.down"
                        } else {
                            yVal = 0
                            direction = "arrow.up"
                        }
                    }
                    if xVal == 0 && yVal == 0 {
                        direction = "arrow.up.left"
                    } else if xVal == screenWidth - 150 && yVal == 0 {
                        direction = "arrow.up.right"
                    } else if xVal == 0 && yVal == screenHeight - 80 {
                        direction = "arrow.down.left"
                    } else if xVal == screenWidth - 150 && yVal == screenHeight - 80 {
                        direction = "arrow.down.right"
                    }
                    
                    //print(xVal, yVal)
                    if self.nodeButton.keys.contains(node.key) {
                        DispatchQueue.main.async {
                            self.nodeButton[node.key]?.updateImage(name: direction)
                            self.nodeButton[node.key]?.frame = CGRect(x: xVal, y: yVal, width: 150, height: 80)
                        }
                    } else {
                        let directionView = DirectionView()
                        directionView.deviceId = node.key
                        directionView.userName = self.machineList[node.key]?.userName ?? ""
                        directionView.commonInit()
                        directionView.layer.borderWidth = 3.0
                        directionView.layer.borderColor = ColorGenerator.sharedInstance.next().cgColor
                        directionView.layer.cornerRadius = 8.0
                        directionView.updateImage(name: direction)
                        directionView.frame = CGRect(x: xVal, y: yVal, width: 150, height: 80)
                        self.nodeButton[node.key] = directionView
                        DispatchQueue.main.async {
                            self.view.addSubview(directionView)
                        }
                    }
                    
                } else {
                    if self.nodeButton.keys.contains(node.key) {
                        DispatchQueue.main.async {
                            self.nodeButton[node.key]?.removeFromSuperview()
                            self.nodeButton.removeValue(forKey: node.key)
                        }
                    }
                }
            }
            lastUpdateTime = time
        }
        os_signpost(.end, log: logHandle, name: "Process A", signpostID: spid)
    }
    
    func generateRectangleNode(displayMachine: MachineModel?) -> SCNNode {
        let fontScale: Float = 0.02
        var width: Float = 0
        var height: Float = 0
        var nodeList: [SCNNode] = []
        var count = 0
        var min = SCNVector3()
        var max = SCNVector3()
        if let id: String = displayMachine?.managementId {
            count = count + 1
            let idText = SCNText(string: id, extrusionDepth: 0.1)
            idText.firstMaterial?.diffuse.contents = UIColor.darkGray
            idText.font = UIFont.systemFont(ofSize: 1)
            idText.flatness = 0.005
            let idNode = SCNNode(geometry: idText)
            idNode.scale = SCNVector3(fontScale, fontScale, fontScale)
            (min, max) = (idText.boundingBox.min, idText.boundingBox.max)
            width = (max.x - min.x) * fontScale
            height = (max.y - min.y) * fontScale
            nodeList.append(idNode)
        }
        if let type: String = displayMachine?.type {
            count = count + 1
            let typeText = SCNText(string: type, extrusionDepth: 0.1)
            typeText.firstMaterial?.diffuse.contents = UIColor.darkGray
            typeText.font = UIFont.systemFont(ofSize: 0.8)
            typeText.flatness = 0.005
            let typeNode = SCNNode(geometry: typeText)
            typeNode.scale = SCNVector3(fontScale, fontScale, fontScale)
            nodeList.append(typeNode)
        }
        
        if let group: String = displayMachine?.group {
            count = count + 1
            let groupText = SCNText(string: group, extrusionDepth: 0.1)
            groupText.firstMaterial?.diffuse.contents = UIColor.darkGray
            groupText.font = UIFont.systemFont(ofSize: 0.8)
            groupText.flatness = 0.005
            let groupNode = SCNNode(geometry: groupText)
            groupNode.scale = SCNVector3(fontScale, fontScale, fontScale)
            nodeList.append(groupNode)
        }
        if let name: String = displayMachine?.userName {
            count = count + 1
            let nameText = SCNText(string: name, extrusionDepth: 0.1)
            nameText.firstMaterial?.diffuse.contents = UIColor.darkGray
            nameText.font = UIFont.systemFont(ofSize: 0.8)
            nameText.flatness = 0.005
            let nameNode = SCNNode(geometry: nameText)
            nameNode.scale = SCNVector3(fontScale, fontScale, fontScale)
            nodeList.append(nameNode)
        }
        let billboardConstraint = SCNBillboardConstraint()
        billboardConstraint.freeAxes = [.X, .Y]
        let planeHeight = height * Float(count+8)
        let planeWidth = width * 1.6
        let plane = SCNPlane(width: CGFloat(planeWidth), height: CGFloat(planeHeight))
        let planeNode = SCNNode(geometry: plane)
        planeNode.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "border")
        planeNode.geometry?.firstMaterial?.isDoubleSided = true
        planeNode.position = nodeList[count-1].position
        planeNode.constraints = [billboardConstraint]
        
        for (index, node) in nodeList.enumerated() {
            let dx = min.x + 0.5 * (max.x - min.x) + width * 0.2
            var dy = max.y - min.y
            dy = dy * (Float(index) + 0.5)
            let dz = min.z + 0.5 * (max.z - min.z)
            node.pivot = SCNMatrix4MakeTranslation(dx, dy, dz)
            node.eulerAngles = planeNode.eulerAngles
            node.constraints = [billboardConstraint]
            planeNode.addChildNode(node)
        }
        return planeNode
    }
}

extension SCNVector3{
    func distance(vector: SCNVector3) -> Float {
        return simd_distance(simd_float3(self), simd_float3(vector))
    }
}
