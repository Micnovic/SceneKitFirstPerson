//
//  ContentView.swift
//  SceneKitTest
//
//  Created by Глеб Михновец on 05.01.2022.
//

import SwiftUI
import SceneKit
import CoreGraphics

struct ContentView: View {
	
	@StateObject var model: Model = Model()
	@State var isOverContentView: Bool = false
	var mouseLocation: NSPoint { NSEvent.mouseLocation }
	@State var mouseLocX: Double = 0
	@State var mouseLocY: Double = 0
	@State var mousePreviousLocation: NSPoint = NSMakePoint(CGFloat(0), CGFloat(0))
	
	var body: some View {
		ZStack{
			VStack{
				SceneView(
					scene: model.myScene,
					pointOfView: model.cameraNode,
					options: [
						.rendersContinuously
					],
					delegate: model
				)
			}
			.onHover {isMouseIn in
				mouseLocX = mouseLocation.x
				mouseLocY = mouseLocation.y
				isOverContentView = isMouseIn
			}
			.onAppear(
				perform: {
					//Key events
					NSEvent.addLocalMonitorForEvents(matching: [.keyDown]) {
						event in
						if event.isARepeat { return nil }
						let pressedChar = event.charactersIgnoringModifiers!
						//print(pressedChar)
						func addSimdToSCN3(_ scn: SCNVector3, _ simd: simd_float3) -> SCNVector3 {
							var result = scn
							result.x += CGFloat(simd.x)
							result.y += CGFloat(simd.y)
							result.z += CGFloat(simd.z)
							return result
						}
						switch pressedChar {
						case "w":
							model.cameraForwardSpeed += model.movementSpeed
						case "s":
							model.cameraForwardSpeed -= model.movementSpeed
						case "a":
							model.cameraRightSpeed -= model.movementSpeed
						case "d":
							model.cameraRightSpeed += model.movementSpeed
						//case "q":
							//exit(0)
						default:
							return nil
						}
						return nil
					}
					
					NSEvent.addLocalMonitorForEvents(matching: [.keyUp]) {
						event in
						if event.isARepeat { return nil }
						let pressedChar = event.charactersIgnoringModifiers!
						switch pressedChar {
						case "w":
							model.cameraForwardSpeed -= model.movementSpeed
						case "s":
							model.cameraForwardSpeed += model.movementSpeed
						case "a":
							model.cameraRightSpeed += model.movementSpeed
						case "d":
							model.cameraRightSpeed -= model.movementSpeed
						default:
							return nil
						}
						return nil
					}
					
					//Mouse events
					NSEvent.addLocalMonitorForEvents(matching: [.mouseMoved]) {
						//print("\(isOverContentView ? "Mouse inside ContentView" : "Not inside Content View") x: \(self.mouseLocation.x) y: \(self.mouseLocation.y)")
						
						var translation: CGPoint = mousePreviousLocation
						translation.x -= mouseLocation.x
						translation.y -= mouseLocation.y
						
						if mouseLocation.x >= CGFloat(CGDisplayPixelsWide(CGMainDisplayID()) - 1) {
							CGDisplayMoveCursorToPoint(CGMainDisplayID(), CGPoint(x: 2, y: mouseLocation.y))
						}
						
						if mouseLocation.x <= 1 {
							CGDisplayMoveCursorToPoint(CGMainDisplayID(), CGPoint(x: CGFloat(CGDisplayPixelsWide(CGMainDisplayID()) - 2), y: mouseLocation.y))
						}
						
						if mouseLocation.y >= CGFloat(CGDisplayPixelsHigh(CGMainDisplayID()) - 1) {
							CGDisplayMoveCursorToPoint(CGMainDisplayID(), CGPoint(x: mouseLocation.x, y: CGFloat(CGDisplayPixelsHigh(CGMainDisplayID()) - 2)))
						} //Attention! Mouse jumps in another coordinate system!!! Y-axis is flipped.
						
						if mouseLocation.y <= 1 {
							CGDisplayMoveCursorToPoint(CGMainDisplayID(), CGPoint(x: mouseLocation.x, y:2))
						} //Attention! Mouse jumps in another coordinate system!!! Y-axis is flipped.
						
						var currentRotation = model.cameraNode!.eulerAngles
						
						currentRotation.y += (translation.x / 1000) * CGFloat(model.rotationSpeed)
						currentRotation.x -= (translation.y / 1000) * CGFloat(model.rotationSpeed)
						
						model.cameraNode!.eulerAngles = currentRotation
						
						mousePreviousLocation.x = mouseLocation.x
						mousePreviousLocation.y = mouseLocation.y
						
						//isOverContentView ? CGDisplayHideCursor(CGMainDisplayID()) : CGDisplayShowCursor(CGMainDisplayID())
						
						return $0
					}
				}
			)
		}
	}
}

class Model: NSObject, ObservableObject, SCNSceneRendererDelegate {
	@Published var myScene: SCNScene?
	@Published var cameraNode: SCNNode?
	@Published var movementSpeed: Float = 0.1
	@Published var rotationSpeed: Float = 2.0
	@Published var cameraForwardSpeed: Float = 0
	@Published var cameraRightSpeed: Float = 0
	
	override init() {
		super.init()
		myScene = SCNScene(named: "SceneKit Scene.scn")
		cameraNode = myScene?.rootNode.childNode(withName: "camera", recursively: false)
	}
	
	func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
		
		let forwardVector: simd_float3 = cameraNode!.simdWorldFront
		let backwardVector = -forwardVector
		let rightVector: simd_float3 = cameraNode!.simdWorldRight
		let leftVector: simd_float3 = -rightVector
		
		cameraNode!.position.x =  cameraNode!.position.x + CGFloat(forwardVector.x) * CGFloat(cameraForwardSpeed) + CGFloat(rightVector.x) * CGFloat(cameraRightSpeed)
		cameraNode!.position.y =  cameraNode!.position.y + CGFloat(forwardVector.y) * CGFloat(cameraForwardSpeed) + CGFloat(rightVector.y) * CGFloat(cameraRightSpeed)
		cameraNode!.position.z =  cameraNode!.position.z + CGFloat(forwardVector.z) * CGFloat(cameraForwardSpeed) + CGFloat(rightVector.z) * CGFloat(cameraRightSpeed)
		
		
	}
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView()
	}
}
