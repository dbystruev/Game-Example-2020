//
//  GameViewController.swift
//  Game Example
//
//  Created by Denis Bystruev on 03.10.2020.
//

import UIKit
import QuartzCore
import SceneKit

class GameViewController: UIViewController {
    
    let label = UILabel()
    var ship: SCNNode!
    var scene: SCNScene!
    var scnView: SCNView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create a new scene
        scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // remove the ship
        removeShip()
        
        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
        
        // place the camera
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 0)
        
        // create and add a light to the scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = .omni
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        scene.rootNode.addChildNode(lightNode)
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = UIColor.darkGray
        scene.rootNode.addChildNode(ambientLightNode)
        
        // animate the 3d object
//        ship.runAction(
//            SCNAction.repeatForever(
//                SCNAction.rotateBy(x: 0, y: 2 * .pi, z: 0, duration: 1)
//            )
//        )
        
        // retrieve the SCNView
        scnView = view as? SCNView
        
        // set the scene to the view
        scnView.scene = scene
        
        // allows the user to manipulate the camera
        scnView.allowsCameraControl = true
        
        // show statistics such as fps and timing information
        scnView.showsStatistics = true
        
        // configure the view
        scnView.backgroundColor = UIColor.black
        
        // add a tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        scnView.addGestureRecognizer(tapGesture)
        
        // Add ship to the scene
        ship = getShip()
        addShip()
        
        // Add label to the scene view
        scnView.addSubview(label)
        label.frame = CGRect(x: 0, y: 0, width: scnView.frame.width, height: 50)
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 30)
    }
    
    func addShip() {
        scnView.scene?.rootNode.addChildNode(ship)
    }
    
    func getShip() -> SCNNode {
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        let ship = scene.rootNode.childNode(withName: "ship", recursively: true)!.clone()
        
        // Move ship out of view
        ship.position.z = -105
        
        // Add ship animation
        ship.runAction(.move(to: SCNVector3(), duration: 5)) {
            ship.removeFromParentNode()
            DispatchQueue.main.async {
                self.label.text = "Game Over"
            }
        }
        
        return ship
    }
    
    func removeShip() {
        scene?.rootNode.childNode(withName: "ship", recursively: true)?.removeFromParentNode()
    }
    
    @objc
    func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // check what nodes are tapped
        let p = gestureRecognize.location(in: scnView)
        let hitResults = scnView.hitTest(p, options: [:])
        // check that we clicked on at least one object
        if hitResults.count > 0 {
            // retrieved the first clicked object
            let result = hitResults[0]
            
            // get its material
            let material = result.node.geometry!.firstMaterial!
            
            // highlight it
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.2
            
            // on completion - unhighlight
            SCNTransaction.completionBlock = {
                self.ship.removeAllActions()
                self.ship.removeFromParentNode()
                self.ship = self.getShip()
                self.addShip()
            }
            
            material.emission.contents = UIColor.red
            
            SCNTransaction.commit()
        }
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

}
