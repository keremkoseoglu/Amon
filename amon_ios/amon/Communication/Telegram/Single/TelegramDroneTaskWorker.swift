//
//  TelegramDroneTaskWorker.swift
//  amon
//
//  Created by Dr. Kerem Koseoglu on 24.04.2019.
//  Copyright © 2019 Dr. Kerem Koseoglu. All rights reserved.
//

import Foundation
import MapKit
import EasyHTTP
import EasyTelegram

class TelegramDroneTaskWorker : TelegramTaskWorker, HttpClient, TelegramBotReplyListenerClient {

	private var botListener: TelegramBotReplyListener!
	
	internal var currentWorkClient: TelegramWorkClient?
	internal var droneID: String
	internal var result: WorkResult!
	
	init(pDroneID: String) {
		droneID = pDroneID
	}
	
	////////////////////////////////////////////////////////////
	// Stuff to override
	////////////////////////////////////////////////////////////
	
	internal func getBotQuestionCommand() -> String {
		assertionFailure()
		return ""
	}
	
	internal func getBotReplyCommand() -> String {
		assertionFailure()
		return ""
	}
	
	internal func handleBotReply(_ reply: TelegramBotReply) {assertionFailure()}
	
	////////////////////////////////////////////////////////////
	// Worker
	////////////////////////////////////////////////////////////
	
	func work(taskID: String, workClient: TelegramWorkClient?) {
		result = WorkResult(pTaskID: taskID, pSuccess: false, pError: "")
		currentWorkClient = workClient
		botListener = TelegramBotReplyListener(botReply:getBotReplyCommand(), botID: droneID, pClient: self)
		TelegramHttp.sendMessageToRoom(getBotQuestionCommand(), httpClient: self)
		botListener.listen()
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
		botListener.listen()
	}
	
	////////////////////////////////////////////////////////////
	// Bot reply listener
	////////////////////////////////////////////////////////////
	
	func botReply(botID: String, success: Bool, reply: TelegramBotReply, error: String) {
		result.success = success
		result.error = error
		if success { handleBotReply(reply) } else { currentWorkClient?.workCompleted(result: result) }
	}
	
}

