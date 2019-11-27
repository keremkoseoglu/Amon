//
//  TelegramDronePhoto.swift
//  amon
//
//  Created by Dr. Kerem Koseoglu on 15.04.2019.
//  Copyright © 2019 Dr. Kerem Koseoglu. All rights reserved.
//

import Foundation
import UIKit
import EasyHTTP
import EasyTelegram

class TelegramDronePhoto : TelegramDroneTaskWorker, TelegramPhotoDownloaderClient {
	
	private var downloadedImage: UIImage!
	private var photoDownloader: TelegramPhotoDownloader!
	
	////////////////////////////////////////////////////////////
	// Own stuff
	////////////////////////////////////////////////////////////
	
	func getDroneID() -> String {return droneID}
	
	func getDronePhoto() -> UIImage {
		if downloadedImage != nil {return downloadedImage}
		return UIImage(ciImage: CIImage.init(color:CIColor.black))
	}
	
	////////////////////////////////////////////////////////////
	// Stuff to override
	////////////////////////////////////////////////////////////
	
	override internal func getBotQuestionCommand() -> String {
		return "/shoot_photo drone:" + droneID
	}
	
	override internal func getBotReplyCommand() -> String {
		return "/my_photo"
	}
	
	override internal func handleBotReply(_ reply: TelegramBotReply) {
		photoDownloader = TelegramPhotoDownloader()
		photoDownloader.downloadImage(pFileID: reply.getValue("photo"), pClient: self)
	}
	
	////////////////////////////////////////////////////////////
	// Telegram photo download listener
	////////////////////////////////////////////////////////////
	
	func downloadComplete(image: UIImage, success: Bool, error: String) {
		result.success = success
		result.error = error
		
		if success { downloadedImage = image }
		currentWorkClient?.workCompleted(result: result)
	}
	
}
