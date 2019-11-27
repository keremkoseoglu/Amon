//
//  TelegramCommunicator.swift
//  amon
//
//  Created by Dr. Kerem Koseoglu on 12.04.2019.
//  Copyright © 2019 Dr. Kerem Koseoglu. All rights reserved.
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

struct TelegramCommunicationTask {
	var telegramTask: TelegramTask
	var caller: Caller?
	
	init(pTask: TelegramTask, pCaller: Caller?) {
		telegramTask = pTask
		caller = pCaller
	}
}

class TelegramCommunicator : Communicator, TelegramTaskClient {
	
	private static var DEFAULT_FREQUENCY: Double = 5
	
	private var communicationTasks: [TelegramCommunicationTask]
	private var longPollSubmitTimer: Timer!
	
	private var longPollTaskManager: TelegramTaskManager
	private var defaultTaskManager: TelegramTaskManager
	
	////////////////////////////////////////////////////////////
	// Constructor
	////////////////////////////////////////////////////////////
	
	init() {
		communicationTasks = [TelegramCommunicationTask]()
		longPollTaskManager = TelegramTaskManager()
		defaultTaskManager = TelegramTaskManager()
	}
	
	////////////////////////////////////////////////////////////
	// Communicator
	////////////////////////////////////////////////////////////
	
	func abortProject(project: Project, caller: Caller) { addTask(worker: TelegramProjectAbort(pProject: project), caller: caller) }
	
	func announce(message: String, caller: Caller) { addTask(worker: TelegramAnnouncement(pMessage: message), caller: caller) }
	
	func getDroneList(_ caller: Caller) { addTask(worker: TelegramBotAdminList(), caller: caller) }
	
	func getDronePhoto(droneID: String, caller: Caller) { addTask(worker: TelegramDronePhoto(pDroneID:droneID), caller: caller) }
	
	func getDroneState(droneID: String, caller: Caller) { addTask(worker: TelegramDroneStatus(pDroneID:droneID), caller: caller) }
	
	func refreshProject(project: Project, caller: Caller) { addTask(worker: TelegramProjectRefresh(pProject: project), caller: caller) }
	
	func setupProject(project: Project, caller: Caller) { addTask(worker: TelegramProjectSetup(pProject: project), caller: caller) }
	
	func startProject(project: Project, caller: Caller) { addTask(worker: TelegramProjectStart(pProject: project), caller: caller) }
	
	func startUp() {
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
	
	func test(_ caller: Caller) { addTask(worker: TelegramTester(), caller: caller) }
	
	////////////////////////////////////////////////////////////
	// Task Client
	////////////////////////////////////////////////////////////
	
	func taskCompleted(result: WorkResult) {
		
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
				
				if ct.telegramTask.worker is TelegramBotAdminList {
					let droneListWorker = ct.telegramTask.worker as! TelegramBotAdminList
					ct.caller?.droneListFetched(result: communicatorResult, droneList: droneListWorker.botAdminList)
				}
				
				if ct.telegramTask.worker is TelegramDroneStatus {
					let tds = ct.telegramTask.worker as! TelegramDroneStatus
					
					ct.caller?.droneStateCompleted(
						result: communicatorResult,
						droneState: tds.getDroneState()
					)
				}
				
				if ct.telegramTask.worker is TelegramProjectSetup {
					ct.caller?.setupProjectCompleted(result: communicatorResult)
				}
				
				if ct.telegramTask.worker is TelegramProjectStart {
					ct.caller?.startProjectCompleted(result: communicatorResult)
				}
				
				if ct.telegramTask.worker is TelegramDronePhoto {
					let tdp = ct.telegramTask.worker as! TelegramDronePhoto
					ct.caller?.dronePhotoCompleted(result: communicatorResult, photo: tdp.getDronePhoto(), droneID: tdp.getDroneID())
				}
				
				if ct.telegramTask.worker is TelegramProjectAbort {
					ct.caller?.abortProjectCompleted(result: communicatorResult)
				}
				
				if ct.telegramTask.worker is TelegramAnnouncement {
					ct.caller?.announcementCompleted(result: communicatorResult)
				}
				
				if ct.telegramTask.worker is TelegramProjectRefresh {
					ct.caller?.refreshProjectCompleted(result: communicatorResult)
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
	
	private func addTask(worker: TelegramTaskWorker, caller: Caller?) {
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
