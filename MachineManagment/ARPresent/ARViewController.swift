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

protocol MapDirectionDelegate {
    func setDistance(x: Float, y: Float)
}

class ARViewController: UIViewController, ObservableObject {
    
    var sceneView: ARSCNView = ARSCNView()
    var arViewPresentDelegate: ARViewPresentDelegate?
    var mapDirectionDelegate: MapDirectionDelegate?
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
    
    
    //Properties for MapDirectionView
    var oneMachine: MachineModel?
    
//    @Published var distance: String? {
//        willSet {
//            objectWillChange.send()
//        }
//    }
    
    public func initProcess() {
        super.viewDidLoad()
        sceneView = ARSCNView(frame: UIScreen.main.bounds)
        self.sceneView.delegate = self
        view.addSubview(sceneView)
        if self.arViewPresentDelegate != nil {
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
            self.loadBarButtonItemDidTouch()
        } else {
            self.selectView.removeFromSuperview()
            self.settingView.removeFromSuperview()
            self.loadDeviceFrom2DMap()
        }
        self.configureLighting()
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
                    DBManager.sharedInstance.saveMachineMapCoordinates(id: key, position: device.transform)
                }
                try self.archive(worldMap: worldMap)
                DispatchQueue.main.async {
                    self.arViewPresentDelegate?.setMessage(text: "World map is saved.")
                    DBManager.sharedInstance.saveWorldMapModel(path: self.worldString)
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
                let anchorMatrix: simd_float4x4 = self.anchorInfoTransfer(anchorInfo: anchorModel)
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
    
    //初期化
    func resetTrackingConfigurationViaMapDirectionView(with worldMap: ARWorldMap? = nil) {
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
    
    func anchorInfoTransfer(anchorInfo: AnchorModel) -> simd_float4x4 {
        var anchorMatrix: simd_float4x4 = simd_float4x4()
        if anchorInfo.anchorList.count == 16{
            anchorMatrix.columns.0 = simd_float4(arrayLiteral: anchorInfo.anchorList[0],anchorInfo.anchorList[1],anchorInfo.anchorList[2],anchorInfo.anchorList[3] )
            anchorMatrix.columns.1 = simd_float4(arrayLiteral: anchorInfo.anchorList[4],anchorInfo.anchorList[5],anchorInfo.anchorList[6],anchorInfo.anchorList[7] )
            anchorMatrix.columns.2 = simd_float4(arrayLiteral: anchorInfo.anchorList[8],anchorInfo.anchorList[9],anchorInfo.anchorList[10],anchorInfo.anchorList[11] )
            anchorMatrix.columns.3 = simd_float4(arrayLiteral: anchorInfo.anchorList[12],anchorInfo.anchorList[13],anchorInfo.anchorList[14],anchorInfo.anchorList[15] )
        }
        return anchorMatrix
    }
    
    
    //node位置計算
//    func doAnchorCalculation() {
//
//    }
//
}

extension ARViewController {
    
    //初期化（２Dマップ）
    func loadDeviceFrom2DMap() {
        if let oneMachine: MachineModel = self.oneMachine {
            let anchorInfo: AnchorModel = DBManager.sharedInstance.getAnchorModelBy(deviceId: oneMachine.managementId)
            do {
                let worldURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                    .appendingPathComponent("worldMapURL_" + anchorInfo.worldMap)
                if let worldMapData = retrieveWorldMapData(from: worldURL),
                    let worldMap = unarchive(worldMapData: worldMapData) {
                    resetTrackingConfigurationViaMapDirectionView(with: worldMap)
                } else {
                    resetTrackingConfigurationViaMapDirectionView()
                }
            } catch {
                print("Error retrieving world map data.")
                return
            }
            
            let anchorMatrix: simd_float4x4 = self.anchorInfoTransfer(anchorInfo: anchorInfo)
            let anchor = ARAnchor(name: anchorInfo.managementId, transform: anchorMatrix)
            print(anchorInfo.managementId)
            print(anchor.transform.columns.3.x,anchor.transform.columns.3.y, anchor.transform.columns.3.z)
            self.tempAnchorList[anchorInfo.managementId] = anchor
            let rectangleNode = self.generateRectangleNode(displayMachine: oneMachine)
            self.nodeList[anchorInfo.managementId] = rectangleNode
            sceneView.session.add(anchor: anchor)
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
            if self.arViewPresentDelegate == nil {
                for node in self.nodeList {
                    let end = node.value.presentation.worldPosition
                    let start = pointOfView.worldPosition
                    let dx = end.x - start.x
                    let dy = end.y - start.y
                    let dz = end.z - start.z
                    //need to fix
                    //print(String(sqrt(pow(dx,2)+pow(dy,2)+pow(dz,2))))
                    self.mapDirectionDelegate?.setDistance(x: -dx, y: -dz)
                }
            } else {
                for node in self.nodeList {
                    let isVisible = renderer.isNode(node.value, insideFrustumOf: pointOfView)
                    let xDistance = node.value.convertPosition(node.value.position, to: pointOfView).x
                    let yDistance = node.value.convertPosition(node.value.position, to: pointOfView).y
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
