//
//  Communicator.swift
//  amon
//
//  Created by Dr. Kerem Koseoglu on 11.04.2019.
//  Copyright © 2019 Dr. Kerem Koseoglu. All rights reserved.
//

import Foundation
import UIKit
import amongst

/*
Steps to add a new func here:
- add a new funcCompleted to Caller (+where used list)
- add the new func to Communicator
- Implement the new func to Communicator subclasses (such as TelegramCommunicator); check the commentary there
- External: Bastion should support this new command, check AmonRequest
*/

struct CommunicatorResult {
	var success: Bool
	var error: String
	
	init(pSuccess:Bool=false, pError:String="") {
		success = pSuccess
		error = pError
	}
}

protocol Caller {
	func abortProjectCompleted(result: CommunicatorResult)
	func announcementCompleted(result: CommunicatorResult)
	func droneListFetched(result: CommunicatorResult, droneList: [String])
	func dronePhotoCompleted(result: CommunicatorResult, photo: UIImage, droneID: String)
	func droneStateCompleted(result: CommunicatorResult, droneState: DroneState)
	func initCompleted(_ result: CommunicatorResult)
	func refreshProjectCompleted(result: CommunicatorResult)
	func setupProjectCompleted(result: CommunicatorResult)
	func startProjectCompleted(result: CommunicatorResult)
	func testCompleted(_ result: CommunicatorResult)
}

protocol Communicator {
	func abortProject(project: Project, caller: Caller)
	func announce(message: String, caller: Caller)
	func getDroneList(_ caller: Caller)
	func getDronePhoto(droneID: String, caller: Caller)
	func getDroneState(droneID: String, caller: Caller)
	func refreshProject(project: Project, caller: Caller)
	func setupProject(project: Project, caller: Caller)
	func startProject(project: Project, caller: Caller)
	func startUp()
	func test(_ caller: Caller)
}

class CommunicatorFactory {
	
	private static var singleton: Communicator!
	
	static func getCommunicator() -> Communicator {
		if singleton == nil {
			MutCommunicator.getInstance().runErrands()
			singleton = TelegramCommunicator()
			singleton.startUp()
		}
		return singleton
	}
	
}
