//
//  Communicator.swift
//  Bast
//
//  Created by Dr. Kerem Koseoglu on 7.05.2019.
//  Copyright © 2019 DJI. All rights reserved.
//

/*
Steps to add a new func here:
- add a new funcCompleted to Caller (+where used list)
- add the new func to Communicator
- Implement the new func to Communicator subclasses (such as TelegramCommunicator); check the commentary there
*/

import Foundation

public struct CommunicatorResult {
	public var success: Bool
	public var error: String
	
	public init(pSuccess:Bool=false, pError:String="") {
		success = pSuccess
		error = pError
	}
}

public protocol Caller {
	func newAmonCommands(result: CommunicatorResult, commands: [AmonRequest])
	func testCompleted(_ result: CommunicatorResult)
}

public protocol Communicator {
	func getNewAmonCommands(caller: Caller)
	func replyAmon(message: String)
	func startUp()
	func test(_ caller: Caller)
}

public class CommunicatorFactory {
	
	private static var singleton: Communicator!
	
	public static func getCommunicator() -> Communicator {
		if singleton == nil {			
			singleton = TelegramCommunicator()
			singleton.startUp()
		}
		return singleton
	}
	
}
