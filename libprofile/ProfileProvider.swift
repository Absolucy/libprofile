//
//  Provider.swift
//  libprofile
//
//  Created by Aspen on 6/7/21.
//

import UIKit

@objc protocol ProfileProvider {
	@objc func contactPhoto(request: NCNotificationRequest, with header: String, with body: String, callback: @escaping (UIImage) -> Void);
}
