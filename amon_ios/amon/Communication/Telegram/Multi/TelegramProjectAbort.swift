//
//  TelegramProjectAbort.swift
//  amon
//
//  Created by Dr. Kerem Koseoglu on 16.04.2019.
//  Copyright © 2019 Dr. Kerem Koseoglu. All rights reserved.
//

import Foundation
import EasyTelegram

class TelegramProjectAbort : TelegramEmployedDronesTaskWorker {
	
	override internal func getBotCommand(employedDrone:ProjectDrone) -> String {
		return "/abort_project drone:" + employedDrone.drone.state.name + " project:" + project.projectID
	}
	
	override internal func getExpectedBotReply() -> String {
		return "/my_project_abort"
	}
	
	override internal func handleEmployedBotReply(repliedDrone: ProjectDrone, success: Bool, reply: TelegramBotReply, error: String) {
		
		if reply.getValue("project") == project.projectID {
			if success {
				repliedDrone.drone.state.isOccupied = false
				repliedDrone.drone.state.lastInfo = reply.getValue("info")
			}
			else {
				repliedDrone.drone.state.lastInfo = error
			}
		}
	}
	
}
