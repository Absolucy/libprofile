//
//  Messages.swift
//  libprofile
//
//  Created by Andromeda on 08/06/2021.
//

import UIKit
import AddressBook
import AddressBookUI
import Contacts

@objc class MessagesProfileProvider: NSObject, ProfileProvider {

	@objc func contactPhoto(request: NCNotificationRequest, with header: String, with body: String, callback: @escaping (UIImage) -> Void) {
		guard let userNotif = request.userNotification else { return }
		// Get the autor information out of the user notification.
		let userReq = userNotif.request
		let userContent = userReq.content
		let info = userContent.userInfo
		
		var contacts = [CNContact]()
		var identifier: NSString?
		if let localIdentifier = info["CKBBContextKeySenderPersonCentricID"] as? NSString {
			identifier = localIdentifier
		} else if let localIdentifier = info["CKBBContextKeySenderName"] as? NSString {
			identifier = localIdentifier
		}
		if let identifier = identifier {
			let addressBook = CNContactStore()
			do {
				try addressBook.containers(matching: CNContainer.predicateForContainers(withIdentifiers: [addressBook.defaultContainerIdentifier()]))
				let keysToFetch = [CNContactEmailAddressesKey, CNContactPhoneNumbersKey, CNContactGivenNameKey, CNContactImageDataKey] as [CNKeyDescriptor]
				let contactRequest = CNContactFetchRequest(keysToFetch: keysToFetch)
				try addressBook.enumerateContacts(with: contactRequest) { contact, _ in
					let contactIdentifier = contact.identifier
					if contactIdentifier == identifier as String,
						  contact.imageData != nil {
						contacts.append(contact)
					}
				}
			} catch {
				NSLog("[libprofile] failed to fetch message avatar: \(error.localizedDescription)")
			}
		} else {
			guard let assistantContext = info["AssistantContext"] as? NSDictionary,
				  let msgSender = assistantContext["msgSender"] as? NSDictionary,
				  let identifier = msgSender["displayText"] as? NSString else { return }
			let addressBook = CNContactStore()
			do {
				try addressBook.containers(matching: CNContainer.predicateForContainers(withIdentifiers: [addressBook.defaultContainerIdentifier()]))
				let keysToFetch = [CNContactEmailAddressesKey, CNContactPhoneNumbersKey, CNContactGivenNameKey, CNContactImageDataKey] as [CNKeyDescriptor]
				let contactRequest = CNContactFetchRequest(keysToFetch: keysToFetch)
				try addressBook.enumerateContacts(with: contactRequest) { contact, _ in
					let name = contact.givenName
					if name == identifier as String {
						contacts.append(contact)
					} else {
						let emails = contact.emailAddresses.map(\.value)
						for email in emails {
							if email == identifier {
								contacts.append(contact)
							}
						}
					}
				}
			} catch {
				NSLog("[libprofile] failed to fetch message avatar: \(error.localizedDescription)")
			}
		}
		
		if contacts.isEmpty { return }
		for contact in contacts {
			if let imageData = contact.imageData,
			   var image = UIImage(data: imageData) {
				image = image.compressed
				callback(image)
				return
			}
		}
	}

}

