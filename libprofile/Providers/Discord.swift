//
//  Discord.swift
//  libprofile
//
//  Created by Aspen on 6/7/21.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit

@objc public class DiscordProfileProvider: NSObject, ProfileProvider {

	@objc public func contactPhoto(request: NCNotificationRequest, with header: String, with body: String, callback: @escaping (UIImage) -> Void) {
		guard let userNotif = request.userNotification else { return }
		// Get the autor information out of the user notification.
		let userReq = userNotif.request
		let userContent = userReq.content
		let info = userContent.userInfo
		guard let message = info["message"] as? NSDictionary,
			  let author = message["author"] as? NSDictionary,
			  let avatar = author["avatar"] as? NSString,
			  let id = author["id"] as? String,
			  let url = URL(string: "https://cdn.discordapp.com/avatars/\(id)/\(avatar).png?size=80") else { return }
		// Download the profile picture
		URLSession.shared.dataTask(with: url) { data, response, err in
			// Report error if there is one
			if case let .some(err) = err {
				NSLog("[libprofile] failed to fetch discord avatar: \(err)")
				return
			}
			// Convert our response into a UIImage
			guard let data = data,
				  var img = UIImage(data: data) else { return }
			img = img.compressed
			callback(img)
			// Call the callback
		}.resume()
	}

}
