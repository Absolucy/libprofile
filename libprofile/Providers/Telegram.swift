//
//  Telegram.swift
//  libprofile
//
//  Created by Aspen on 6/8/21.
//

import UIKit

@objc class TelegramProfileProvider: NSObject, ProfileProvider {

	@objc func contactPhoto(request: NCNotificationRequest, with header: String, with body: String, callback: @escaping (UIImage) -> Void) {
		guard let userNotif = request.userNotification,
			  let telegramPath = FolderFinder.findPrivateSharedFolder(appName: "group.ph.telegra.Telegraph") else { return }
		let userReq = userNotif.request
		let userContent = userReq.content
		let info = userContent.userInfo
		// Get the user ID, and the path to their cached avatar
		guard let id = info["from_id"] as? NSString,
				var img = UIImage(contentsOfFile: "\(telegramPath)/telegram-data/accounts-metadata/spotlight/p:\(id)/avatar.png") else { return }
		// Compress the image
		img = img.compressed
		// Call the callback!
		callback(img)
	}

}
