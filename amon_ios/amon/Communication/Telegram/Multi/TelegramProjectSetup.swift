//
//  TelegramProjectSetup.swift
//  amon
//
//  Created by Dr. Kerem Koseoglu on 15.04.2019.
//  Copyright © 2019 Dr. Kerem Koseoglu. All rights reserved.
//

import Foundation
import EasyTelegram

class TelegramProjectSetup : TelegramEmployedDronesTaskWorker {

	override internal func getBotCommand(employedDrone:ProjectDrone) -> String {
		return "/setup_for_project drone:" + employedDrone.drone.state.name + " project:" + project.projectID
	}
	
	override internal func getExpectedBotReply() -> String {
		return "/my_project_setup"
	}
	
	override internal func handleEmployedBotReply(repliedDrone: ProjectDrone, success: Bool, reply: TelegramBotReply, error: String) {

		let info = reply.getValue("info")
		if reply.getValue("project") == project.projectID {
			if success {
				repliedDrone.setSetupComplete(reply.getValue("success") == "TRUE", info: info)
			}
			else {
				repliedDrone.setSetupComplete(false, info: info)
			}
		}
	}
	
}
