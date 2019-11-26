//
//  TelegramCommunicator.swift
//  Bast
//
//  Created by Dr. Kerem Koseoglu on 7.05.2019.
//  Copyright © 2019 DJI. All rights reserved.
//

/*
Steps to add a new Communicator Method:
- Ensure that the func exists under protocol Communicator (check the commentary there)
- add the new protocol method to TelegramCommunicator
- Create a new worker class, similar to TelegramDroneStatus (let's call it X)
- call the new worker class in the new method below (as in getDroneState)
- Ensure that the new class (X) is supported in taskCompleted
*/

import Foundation
import EasyTelegram

public struct TelegramCommunicationTask {
	public var telegramTask: TelegramTask
	public var caller: Caller?
	
	public init(pTask: TelegramTask, pCaller: Caller?) {
		telegramTask = pTask
		caller = pCaller
	}
}

public class TelegramCommunicator : Communicator, TelegramTaskClient {
	
	public static var DEFAULT_FREQUENCY: Double = 5
	
	private var communicationTasks: [TelegramCommunicationTask]
	private var longPollSubmitTimer: Timer!
	
	private var longPollTaskManager: TelegramTaskManager
	private var defaultTaskManager: TelegramTaskManager
	
	////////////////////////////////////////////////////////////
	// Constructor
	////////////////////////////////////////////////////////////
	
	public init() {
		communicationTasks = [TelegramCommunicationTask]()
		longPollTaskManager = TelegramTaskManager()
		defaultTaskManager = TelegramTaskManager()
	}
	
	////////////////////////////////////////////////////////////
	// Communicator
	////////////////////////////////////////////////////////////
	
	public func getNewAmonCommands(caller: Caller) {
		addTask(
			worker: TelegramBotEar.getInstance(),
			caller: caller
		)
	}
	
	public func replyAmon(message: String) {
		addTask(
			worker: TelegramAnnouncement(pMessage: message)
		)
	}
	
	public func startUp() {
		if longPollSubmitTimer == nil {
			
			var interval: Double = Double(TelegramSettings().pollFrequency)
			if interval <= 0 {interval = TelegramCommunicator.DEFAULT_FREQUENCY}
			
			longPollSubmitTimer = Timer.scheduledTimer(
				withTimeInterval: interval,
				repeats: true,
				block: { longPollSubmitTimer in self.requestLongPollUpdate() }
			)
		}
	}
	
	public func test(_ caller: Caller) { addTask(worker: TelegramTester(), caller: caller) }
	
	////////////////////////////////////////////////////////////
	// Task Client
	////////////////////////////////////////////////////////////
	
	public func taskCompleted(result: WorkResult) {
		
		var index = -1
		var removableIndex = -1
		
		for ct in communicationTasks {
			index += 1
			if ct.telegramTask.id == result.taskID {
				removableIndex = index
				
				let communicatorResult = CommunicatorResult(
					pSuccess: result.success,
					pError: result.error
				)
				
				if ct.telegramTask.worker is TelegramTester {
					ct.caller?.testCompleted(communicatorResult)
				}
				
				if ct.telegramTask.worker is TelegramBotEar {
					let tbe = ct.telegramTask.worker as! TelegramBotEar
					ct.caller?.newAmonCommands(result: communicatorResult, commands: tbe.commands)
				}
				
			}
		}
		
		if removableIndex > -1 {
			communicationTasks.remove(at: removableIndex)
		}
	}
	
	////////////////////////////////////////////////////////////
	// Self stuff
	////////////////////////////////////////////////////////////
	
	private func addTask(worker: TelegramTaskWorker, caller:Caller?=nil) {
		let task = TelegramTask(pClient: self, pWorker: worker)
		let commTask = TelegramCommunicationTask(pTask: task, pCaller: caller)
		communicationTasks.append(commTask)
		defaultTaskManager.addTask(task)
	}
	
	private func requestLongPollUpdate() {
		
		let task = TelegramTask(
			pClient: self,
			pWorker: TelegramLongPoll.getInstance()
		)
		
		longPollTaskManager.addTask(task)
	}
	
}
