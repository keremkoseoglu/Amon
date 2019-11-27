//
//  TelegramPhotoDownloadTest.swift
//  amon
//
//  Created by Dr. Kerem Koseoglu on 16.04.2019.
//  Copyright © 2019 Dr. Kerem Koseoglu. All rights reserved.
//

import Foundation
import UIKit
import EasyTelegram

class TelegramPhotoDownloadTest : TelegramPhotoDownloaderClient {
	
/*
	https://api.telegram.org/bot808248142:AAEhftGMYS33gjdfB5OcaEn4P0qk745Qz_0/sendMessage?chat_id=-1001171080087&text=/my_photo%20drone:kkbot03bot%20photo:AgADBAAD27AxG6r6yFEzyMPs4iahZvH-sBoABOaqYuUG2m7JDn8AAgI
*/

	var tpd: TelegramPhotoDownloader!
	
	func testTelegramPhotoDownload() {
		print("Starting photo download")
		tpd = TelegramPhotoDownloader()
		tpd.downloadImage(pFileID: "AgADBAADFa8xG6oWsVF7iujCJLzfmLr0HhsABCsTTiM_LhmWBCMFAAEC", pClient: self)
	}
	
	func downloadComplete(image: UIImage, success: Bool, error: String) {
		if success {
			print("Photo downloaded")
		}
		else {
			print("Cant download photo, error: " + error)
		}
	}
	
}
