//
//  TelegramEmployedDronesTaskWorker.swift
//  amon
//
//  Created by Dr. Kerem Koseoglu on 15.04.2019.
//  Copyright © 2019 Dr. Kerem Koseoglu. All rights reserved.
//

import Foundation
import EasyHTTP
import EasyTelegram

class TelegramEmployedDronesTaskWorker : TelegramTaskWorker, TelegramBotReplyListenerClient, HttpClient {
	
	private var result: WorkResult!
	private var currentWorkClient: TelegramWorkClient?
	private var botListeners: [TelegramBotReplyListener]!
	internal var project: Project
	private var repliedDrones: [String]!
	
	////////////////////////////////////////////////////////////
	// Constructor
	////////////////////////////////////////////////////////////
	
	init(pProject: Project) {
		project = pProject
	}
	
	////////////////////////////////////////////////////////////
	// Methods to override
	////////////////////////////////////////////////////////////
	
	internal func getBotCommand(employedDrone:ProjectDrone) -> String {
		assertionFailure("This func needs to be overriden")
		return ""
	}
	
	internal func getExpectedBotReply() -> String {
		assertionFailure("This func needs to be overriden")
		return ""
	}
	
	internal func handleEmployedBotReply(repliedDrone: ProjectDrone, success: Bool, reply: TelegramBotReply, error: String) {
		assertionFailure("This func needs to be overriden")
	}
	
	////////////////////////////////////////////////////////////
	// Worker
	////////////////////////////////////////////////////////////
	
	func work(taskID: String, workClient: TelegramWorkClient?) {
		result = WorkResult(pTaskID: taskID, pSuccess: false, pError: "")
		currentWorkClient = workClient
		
		let employedDrones = project.getEmployedDrones()
		
		if employedDrones.count <= 0 {
			result.success = false
			result.error = "No employed drones in project"
			currentWorkClient?.workCompleted(result: result)
			return
		}
		
		botListeners = [TelegramBotReplyListener]()
		repliedDrones = [String]()
		
		for employedDrone in employedDrones {
			let botListener = TelegramBotReplyListener(
				botReply:getExpectedBotReply(),
				botID: employedDrone.drone.state.name,
				pClient: self
			)
			botListeners.append(botListener)
			let message = getBotCommand(employedDrone:employedDrone)
			TelegramHttp.sendMessageToRoom(message, httpClient: self)
			botListener.listen()
		}
	}
	
	////////////////////////////////////////////////////////////
	// HTTP
	////////////////////////////////////////////////////////////
	
	func handle_http_error(error: Error) {
		result.error = error.localizedDescription
		currentWorkClient?.workCompleted(result: result)
	}
	
	func handle_http_response(json: [String : Any]) {
		result.success = json["ok"] as? Bool ?? false
		result.error = json["description"] as? String ?? ""
		if !result.success {
			currentWorkClient?.workCompleted(result: result)
			return
		}
	}
	
	////////////////////////////////////////////////////////////
	// Bot Reply
	////////////////////////////////////////////////////////////
	
	func botReply(botID: String, success: Bool, reply: TelegramBotReply, error: String) {
		
		do {
			repliedDrones.append(botID)
			let repliedProjectDrone = try project.getDroneByName(botID)
			
			handleEmployedBotReply(
				repliedDrone: repliedProjectDrone,
				success: success,
				reply: reply,
				error: error
			)

			notifyIfWorkIsComplete()
		}
		catch {
			result.success = false
			result.error += " Drone " + botID + " not in project " + project.projectID
			notifyIfWorkIsComplete()
			return
		}
		
		
	}
	
	////////////////////////////////////////////////////////////
	// Internal stuff
	////////////////////////////////////////////////////////////
	
	private func didAllDronesReply() -> Bool {
		
		let employedDrones = project.getEmployedDrones()
		
		for employedDrone in employedDrones {
			var replied = false
			for repliedDrone in repliedDrones {
				if repliedDrone == employedDrone.drone.state.name {replied = true}
			}
			if !replied {return false}
		}
		
		return true
		
	}
	
	private func notifyIfWorkIsComplete() {
		
		if result.error == "" {
			if !didAllDronesReply() {return}
			let employedDrones = project.getEmployedDrones()
			
			for employedDrone in employedDrones {
				if !employedDrone.isSetupComplete() {
					result.error += " Incomplete drone: " + employedDrone.drone.state.name
				}
			}
		}
		
		result.success = result.error == ""
		currentWorkClient?.workCompleted(result: result)
	}
	
}

