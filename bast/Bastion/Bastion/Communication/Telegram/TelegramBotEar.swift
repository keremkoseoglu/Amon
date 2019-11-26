//
//  TelegramBotEar.swift
//  Bastion
//
//  Created by Dr. Kerem Koseoglu on 8.05.2019.
//  Copyright © 2019 Dr. Kerem Koseoglu. All rights reserved.
//



import Foundation
import EasyTelegram

public class TelegramBotEar: TelegramTaskWorker {
	
	public var commands: [AmonRequest]
	
	private var isWorking: Bool
	private var lastSeenUpdateID: Int
	private var longPoll: TelegramLongPoll
	private var currentWorkClient: TelegramWorkClient?
	private var workResult: WorkResult!
	
	private static var singleton: TelegramBotEar!
	
	////////////////////////////////////////////////////////////
	// Constructor
	////////////////////////////////////////////////////////////
	
	private init() {
		longPoll = TelegramLongPoll.getInstance()
		commands = [AmonRequest]()
		lastSeenUpdateID = 0
		isWorking = false
	}
	
	public static func getInstance() -> TelegramBotEar {
		if singleton == nil {singleton = TelegramBotEar()}
		return singleton
	}
	
	////////////////////////////////////////////////////////////
	// Telegram Task Worker
	////////////////////////////////////////////////////////////
	
	public func work(taskID: String, workClient: TelegramWorkClient?) {
		if (isWorking) {return}
		isWorking = true
		
		workResult = WorkResult(pTaskID: taskID, pSuccess: false, pError: "")
		currentWorkClient = workClient
		
		readCommands()
		
		workResult.success = true
		currentWorkClient?.workCompleted(result: workResult)
		isWorking = false
	}
	
	////////////////////////////////////////////////////////////
	// Own stuff
	////////////////////////////////////////////////////////////
	
	public func passCommands() {
		while true {
			readCommands()
			if commands.count < 0 {return}
		}
	}
	
	private func readCommands() {
		commands = [AmonRequest]()
		
		let ownBotName = Settings.getTelegramSettings().botName
		let messages = longPoll.getMessages()
		
		for message in messages {
			if message.update_id > lastSeenUpdateID {
				lastSeenUpdateID = message.update_id
				
				let parsedMessage = TelegramBotReplyListener.parseBotReplyText( message.text )
				
				if parsedMessage.getValue("drone") == ownBotName {
					switch parsedMessage.command {
					case "/abort_project":
						commands.append(
							AmonRequest(
								pRequestType: AmonRequest.RequestType.projectAbort,
								pProject: parsedMessage.getValue("project")
							)
						)
					case "/get_status":
						commands.append(
							AmonRequest(pRequestType: AmonRequest.RequestType.reportStatus)
						)
					case "/setup_for_project":
						commands.append(
							AmonRequest(
								pRequestType: AmonRequest.RequestType.projectSetup,
								pProject: parsedMessage.getValue("project")
							)
						)
					case "/shoot_photo":
						commands.append(
							AmonRequest(pRequestType: AmonRequest.RequestType.shootPhoto)
						)
					case "/start_project":
						commands.append(
							AmonRequest(
								pRequestType: AmonRequest.RequestType.projectStart,
								pProject: parsedMessage.getValue("project")
							)
						)
					default:
						continue
					}
				}
			}
			
		}
	}
	
}
