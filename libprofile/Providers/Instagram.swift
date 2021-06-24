//
//  Instagram.swift
//  libprofile
//
//  Created by Andromeda on 08/06/2021.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit

@objc public class InstagramProfileProvider: NSObject, ProfileProvider {

	@objc public func contactPhoto(request: NCNotificationRequest, with header: String, with body: String, callback: @escaping (UIImage) -> Void) {
		guard let userNotif = request.userNotification else { return }
		let userReq = userNotif.request
		let userContent = userReq.content
		let info = userContent.userInfo
		guard let urlString = info["a"] as? NSString,
			  let url = URL(string: urlString as String) else { return }
		// Download the profile picture
		URLSession.shared.dataTask(with: url) { data, response, err in
			// Report error if there is one
			if case let .some(err) = err {
				NSLog("[libprofile] failed to fetch instagram avatar: \(err)")
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
