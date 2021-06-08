//
//  UIImage+Compression.swift
//  libprofile
//
//  Created by Andromeda on 08/06/2021.
//

import UIKit

public extension UIImage {
	
	var compressed: UIImage {
		let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
		guard let data = self.pngData() as CFData?,
			  let imageSource = CGImageSourceCreateWithData(data, imageSourceOptions) else { return self }
		let maxDimentionInPixels = max(self.size.width, self.size.height) * UIScreen.main.scale
		let downsampledOptions = [kCGImageSourceCreateThumbnailFromImageAlways: true,
		  kCGImageSourceShouldCacheImmediately: true,
		  kCGImageSourceCreateThumbnailWithTransform: true,
		  kCGImageSourceThumbnailMaxPixelSize: maxDimentionInPixels] as CFDictionary
		guard let downScaledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampledOptions) else { return self }
		return UIImage(cgImage: downScaledImage)
	}
	
}
