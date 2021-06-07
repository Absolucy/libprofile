//
//  Discord.swift
//  libprofile
//
//  Created by Aspen on 6/7/21.
//

import Foundation
import UIKit

@objc class DiscordProfileProvider: NSObject, ProfileProvider {
	@objc func contactPhoto(request: NCNotificationRequest, with header: String, with body: String, callback: @escaping (UIImage) -> Void) {
		guard let userNotif = request.userNotification else { return }
		// Get the autor information out of the user notification.
		let userReq = userNotif.request
		let userContent = userReq.content
		let info = userContent.userInfo
		guard let message = info["message"] as? NSDictionary,
			  let author = message["author"] as? NSDictionary else { return }
		if author["avatar"] == nil {
			return
		}
		// Get the discord user id and avatar id out of the author object
		guard let id = author["id"] as? NSString,
			let avatar = author["avatar"] as? NSString else { return }
		let url = URL(string:  "https://cdn.discordapp.com/avatars/\(id)/\(avatar).png?size=80")!
		// Download the profile picture
		URLSession.shared.dataTask(with: url) { data, response, err in
			// Report error if there is one
			if case let .some(err) = err {
				NSLog("[libprofile] failed to fetch discord avatar: \(err)")
				return
			}
			// Convert our response into a UIImage
			guard let data = data,
				  let img = UIImage(data: data) else { return }
			// Call the given callback!
			DispatchQueue.global(qos: .userInitiated).async {
				callback(img)
			}
			
		}.resume()
	}
}
