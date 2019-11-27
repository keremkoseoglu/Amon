//
//  TelegramProjectRefresh.swift
//  amon
//
//  Created by Dr. Kerem Koseoglu on 20.04.2019.
//  Copyright © 2019 Dr. Kerem Koseoglu. All rights reserved.
//

import Foundation
import UIKit
import EasyTelegram

class TelegramProjectRefresh : TelegramEmployedDronesTaskWorker {
	
	////////////////////////////////////////////////////////////
	// TelegramEmployedDronesTaskWorker
	////////////////////////////////////////////////////////////
	
	override internal func getBotCommand(employedDrone:ProjectDrone) -> String {
		return TelegramDroneStatus.getDroneQuestion(employedDrone.drone.state.name)
	}
	
	override internal func getExpectedBotReply() -> String {
		return TelegramDroneStatus.botReplyCommand
	}
	
	override internal func handleEmployedBotReply(repliedDrone: ProjectDrone, success: Bool, reply: TelegramBotReply, error: String) {
		if success { repliedDrone.drone.state = TelegramDroneStatus.parseReply(reply) }
	}
	
}
