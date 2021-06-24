//
//  Telegram.swift
//  libprofile
//
//  Created by Aspen on 6/8/21.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit

@objc public class TelegramProfileProvider: NSObject, ProfileProvider {

	@objc public func contactPhoto(request: NCNotificationRequest, with header: String, with body: String, callback: @escaping (UIImage) -> Void) {
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
