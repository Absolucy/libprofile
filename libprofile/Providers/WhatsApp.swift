//
//  WhatsApp.swift
//  libprofile
//
//  Created by Andromeda on 08/06/2021.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit

@objc public class WhatsAppProfileProvider: NSObject, ProfileProvider {

	@objc public func contactPhoto(request: NCNotificationRequest, with header: String, with body: String, callback: @escaping (UIImage) -> Void) {
		guard let userNotif = request.userNotification else { return }
		// Get the autor information out of the user notification.
		let userReq = userNotif.request
		let userContent = userReq.content
		let info = userContent.userInfo

		let chatID: String
		var group = false

		if let jid = info["jid"] as? String {
			let parts = jid.components(separatedBy: "-")
			group = parts.count == 2
		}
		if group {
			guard let retry = info["retry-notification-key"] as? NSString else { return }
			let rParts = retry.components(separatedBy: "_")
			guard let last = rParts.last,
				  let localChatID = last.components(separatedBy: "@").first else { return }
			chatID = localChatID
		} else {
			let threadID = request.threadIdentifier
			guard let localChatID = threadID?.components(separatedBy: "@").first else { return }
			chatID = localChatID
		}

		let identifiers = ["group.net.whatsapp.WhatsApp.shared", "group.net.whatsapp.WhatsAppSMB.shared"]
		for identifier in identifiers {
			guard let containerPath = FolderFinder.findSharedFolder(appName: identifier) else { continue }
			let picturesPath = "\(containerPath)/Media/Profile"
			var profilePicture: String?

			guard let files = FileManager.default.enumerator(atPath: picturesPath) else { return }
			for case let url as URL in files {
				let parts = url.lastPathComponent.components(separatedBy: "-")
				if parts.count == 2 {
					if chatID == parts[0] {
						profilePicture = url.lastPathComponent
					}
				}
				if parts.count == 3 {
					if chatID == "\(parts[0])-\(parts[1])" {
						profilePicture = url.lastPathComponent
					}
				}
				if let profilePicture = profilePicture {
					let imagePath = "\(picturesPath)/\(profilePicture)"
					if var image = UIImage(contentsOfFile: imagePath) {
						image = image.compressed
						callback(image)
					}
				}
			}
		}
	}

}

