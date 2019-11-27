//
//  TelegramProjectStart.swift
//  amon
//
//  Created by Dr. Kerem Koseoglu on 15.04.2019.
//  Copyright © 2019 Dr. Kerem Koseoglu. All rights reserved.
//

import Foundation
import EasyTelegram

class TelegramProjectStart : TelegramEmployedDronesTaskWorker {
	
	override internal func getBotCommand(employedDrone:ProjectDrone) -> String {
		return "/start_project drone:" + employedDrone.drone.state.name + " project:" + project.projectID
	}
	
	override internal func getExpectedBotReply() -> String {
		return "/my_project_start"
	}
	
	override internal func handleEmployedBotReply(repliedDrone: ProjectDrone, success: Bool, reply: TelegramBotReply, error: String) {
		
		if reply.getValue("project") == project.projectID {
			if success {
				repliedDrone.drone.state.startedMission = true
				repliedDrone.drone.state.isOccupied = true
			}
			else {
				repliedDrone.drone.state.startedMission = false
				repliedDrone.drone.state.isOccupied = false
				repliedDrone.drone.state.lastInfo = error
			}
		}
	}

}
