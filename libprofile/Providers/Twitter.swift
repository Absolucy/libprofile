//
//  Twitter.swift
//  libprofile
//
//  Created by Andromeda on 08/06/2021.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit

@objc public class TwitterProfileProvider: NSObject, ProfileProvider {

	@objc public func contactPhoto(request: NCNotificationRequest, with header: String, with body: String, callback: @escaping (UIImage) -> Void) {
		guard let userNotif = request.userNotification else { return }
		// Get the autor information out of the user notification.
		let userReq = userNotif.request
		let userContent = userReq.content
		let info = userContent.userInfo


		if let tweet = info["tweet"] as? NSDictionary,
		   let author = tweet["author"] as? NSDictionary {
			guard let urlString = author["profile_image_url"] as? NSString,
			      let url = URL(string: urlString as String) else { return }
			URLSession.shared.dataTask(with: url) { data, response, err in
				// Report error if there is one
				if case let .some(err) = err {
					NSLog("[libprofile] failed to fetch twitter avatar: \(err)")
					return
				}
				// Convert our response into a UIImage
				guard let data = data,
					  var img = UIImage(data: data) else { return }
				img = img.compressed
				callback(img)
				// Call the callback
			}.resume()
		} else {
			guard let d = info["D"] as? NSString else { return }
			let profileURL = "https://mobile.twitter.com/\(d as String)"
			guard let url = URL(string: profileURL) else { return }
			URLSession.shared.dataTask(with: url) { data, response, err in
				guard (response as? HTTPURLResponse)?.statusCode == 200,
					  let data = data,
					  let rawHTML = String(data: data, encoding: .utf8),
					  let regex = try? NSRegularExpression(pattern: "https:\\/\\/pbs\\.twimg\\.com\\/profile_images\\/[^\"]+", options: .caseInsensitive) else { return }
				let matches = regex.matches(in: rawHTML, options: NSRegularExpression.MatchingOptions.init(rawValue: 0), range: NSMakeRange(0, rawHTML.count))
				guard !matches.isEmpty,
					  let first = matches.first,
					  let range = Range(first.range(at: 0), in: rawHTML) else { return }
				let index = range.upperBound
				let urlString = String(rawHTML[index...])
				guard let url = URL(string: urlString) else { return }
				URLSession.shared.dataTask(with: url) { data, response, err in
					// Report error if there is one
					if case let .some(err) = err {
						NSLog("[libprofile] failed to fetch twitter avatar: \(err)")
						return
					}
					// Convert our response into a UIImage
					guard let data = data,
						  var img = UIImage(data: data) else { return }
					img = img.compressed
					callback(img)
					// Call the callback
				}.resume()
			}.resume()
		}
	}

}
