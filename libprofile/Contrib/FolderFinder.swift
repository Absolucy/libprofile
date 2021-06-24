//
//  FolderFinder.swift
//  libprofile
//
//  Created by Andromeda on 08/06/2021.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.


import Foundation

final class FolderFinder: NSObject {
	
	final class func findSharedFolder(appName: String) -> String? {
		let dir = "/var/mobile/Containers/Shared/AppGroup/"
		return FolderFinder.findFolder(appName: appName, folder: dir)
	}
	
	final class func findDataFolder(appName: String) -> String? {
		let dir = "/var/mobile/Containers/Data/Application/"
		return FolderFinder.findFolder(appName: appName, folder: dir)
	}
	
	final class func findPrivateSharedFolder(appName: String) -> String? {
		let dir = "/private/var/mobile/Containers/Shared/AppGroup/"
		return FolderFinder.findFolder(appName: appName, folder: dir)
	}
	
	final class func findFolder(appName: String, folder: String) -> String? {
		guard let folders =  try? FileManager.default.contentsOfDirectory(atPath: folder) else { return nil }
		for _folder in folders {
			let folderPath = folder + _folder
			guard let items = try? FileManager.default.contentsOfDirectory(atPath: folderPath) else { return nil }
			for itemPath in items {
				if let substringRange = itemPath.range(of: ".com.apple.mobile_container_manager.metadata.plist") {
					let range = NSRange(substringRange, in: itemPath)
					if range.location != NSNotFound {
						let fullPath = "\(folderPath)/\(itemPath)"
						let dict = NSDictionary(contentsOfFile: fullPath)
						if let mcmmetdata = dict?["MCMMetadataIdentifier"] as? NSString,
						   mcmmetdata.lowercased == appName.lowercased() {
							return folderPath
						}
					}
				}
			}
		}
		return nil
	}
	
}
