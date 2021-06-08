//
//  FolderFinder.swift
//  libprofile
//
//  Created by Andromeda on 08/06/2021.
//

import Foundation

@objc class FolderFinder: NSObject {
	
	@objc class func findSharedFolder(appName: String) -> String? {
		let dir = "/var/mobile/Containers/Shared/AppGroup/"
		return FolderFinder.findFolder(appName: appName, folder: dir)
	}
	
	@objc class func findDataFolder(appName: String) -> String? {
		let dir = "/var/mobile/Containers/Data/Application/"
		return FolderFinder.findFolder(appName: appName, folder: dir)
	}
	
	@objc class func findPrivateSharedFolder(appName: String) -> String? {
		let dir = "/private/var/mobile/Containers/Shared/AppGroup/"
		return FolderFinder.findFolder(appName: appName, folder: dir)
	}
	
	@objc class func findFolder(appName: String, folder: String) -> String? {
		guard let folders =  try? FileManager.default.contentsOfDirectory(atPath: folder) else { return nil }
		for folder in folders {
			let folderPath = folder.appending(folder)
			guard let items = try? FileManager.default.contentsOfDirectory(atPath: folderPath) else { return nil }
			for itemPath in items {
				guard let substringRange = itemPath.range(of: ".com.apple.mobile_container_manager.metadata.plist") else {
					return nil
				}
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
		return nil
	}
	
}
