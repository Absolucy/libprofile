//
//  Slack.swift
//  libprofile
//
//  Created by Andromeda on 08/06/2021.
//

import UIKit
import SQLite3

@objc class SlackProfileProvider: NSObject, ProfileProvider {

	@objc func contactPhoto(request: NCNotificationRequest, with header: String, with body: String, callback: @escaping (UIImage) -> Void) {
		guard let userNotif = request.userNotification else { return }
		// Get the autor information out of the user notification.
		let userReq = userNotif.request
		let userContent = userReq.content
		let info = userContent.userInfo
		
		guard let aps = info["aps"] as? NSDictionary,
			  let alert = aps["alert"] as? NSDictionary,
			  let body = alert["body"] as? NSString,
			  let threadID = aps["thread-id"] as? NSString,
			  let teamID = info["team_id"] as? NSString else { return }
		let messageType = threadID.substring(to: 1)
		var username: String
		if messageType == "D" {
			guard let localUsername = body.components(separatedBy: ":").first else { return }
			username = localUsername
		} else if messageType == "C" {
			let components = body.components(separatedBy: " ")
			if components.count < 2 { return }
			username = components[1]
		} else { return }
		username = username.replacingOccurrences(of: ":", with: "")
		username = username.replacingOccurrences(of: "@", with: "")
		guard let containerPath = FolderFinder.findDataFolder(appName: "com.tinyspeck.chatlyio") else { return }
		let databasePath = "\(containerPath)/Library/Application Support/Slack/\(teamID)/Database/main_db"
		var slackdb: OpaquePointer?
		guard sqlite3_open(databasePath, &slackdb) == SQLITE_OK else { return }
		defer {
			sqlite3_close(slackdb)
		}
		let stmt = "SELECT 'https://ca.slack-edge.com/' || ZTEAMID || '-' || ZTSID ||  '-' || ZAVATARHASH || '-512' as url FROM ZSLKDEPRECATEDCOREDATAUSER WHERE ZNAME LIKE '%%\(username)%%';"
		var statement: OpaquePointer?
		guard sqlite3_prepare_v2(slackdb, stmt, -1, &statement, nil) == SQLITE_OK else { return }
		defer {
			sqlite3_finalize(statement)
		}
		guard sqlite3_step(statement) == SQLITE_ROW,
			  let result = sqlite3_column_text(statement, 0) else { return }
		let resultString = String(cString: result)
		guard let url = URL(string: resultString) else { return }
		URLSession.shared.dataTask(with: url) { data, response, err in
			// Report error if there is one
			if case let .some(err) = err {
				NSLog("[libprofile] failed to fetch slack avatar: \(err)")
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

