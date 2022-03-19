//
//  ContentView.swift
//  SceneKitTest
//
//  Created by Глеб Михновец on 05.01.2022.
//

import SwiftUI
import SceneKit
import CoreGraphics
import SwiftUI
import SceneKit

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
					scene: model.scene,
					pointOfView: model.cameraNode,
					options: [
						//.rendersContinuously
					]
				)
			}.onHover {isMouseIn in
				mouseLocX = mouseLocation.x
				mouseLocY = mouseLocation.y
				isOverContentView = isMouseIn
			}
			.onAppear(
				perform: {
					//Key events
					NSEvent.addLocalMonitorForEvents(matching: [.keyDown]) {
						event in
						let pressedChar = event.charactersIgnoringModifiers!
						print(pressedChar)
						var currentPosition = model.cameraNode!.position
						let forwardVector: simd_float3 = model.cameraNode!.simdWorldFront
						let backwardVector = -forwardVector
						let rightVector: simd_float3 = model.cameraNode!.simdWorldRight
						let leftVector: simd_float3 = -rightVector
						func addSimdToSCN3(_ scn: SCNVector3, _ simd: simd_float3) -> SCNVector3 {
							var result = scn
							result.x += CGFloat(simd.x)
							result.y += CGFloat(simd.y)
							result.z += CGFloat(simd.z)
							return result
						}
						switch pressedChar {
						case "w":
							currentPosition = addSimdToSCN3(currentPosition, forwardVector * model.movementSpeed)
						case "s":
							currentPosition = addSimdToSCN3(currentPosition, backwardVector * model.movementSpeed)
						case "a":
							currentPosition = addSimdToSCN3(currentPosition, leftVector * model.movementSpeed)
						case "d":
							currentPosition = addSimdToSCN3(currentPosition, rightVector * model.movementSpeed)
						//case "q":
							//exit(0)
						default:
							return nil
						}
						model.cameraNode!.position = currentPosition
						return nil
					}
					
					//Mouse events
					NSEvent.addLocalMonitorForEvents(matching: [.mouseMoved]) {
						print("\(isOverContentView ? "Mouse inside ContentView" : "Not inside Content View") x: \(self.mouseLocation.x) y: \(self.mouseLocation.y)")
						
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

class Model: ObservableObject {
	@Published var scene: SCNScene?
	@Published var cameraNode: SCNNode?
	@Published var movementSpeed: Float = 0.5
	@Published var rotationSpeed: Float = 2.0
	
	init() {
		scene = SCNScene(named: "SceneKit Scene.scn")
		cameraNode = scene?.rootNode.childNode(withName: "camera", recursively: false)
	}
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView()
	}
}
