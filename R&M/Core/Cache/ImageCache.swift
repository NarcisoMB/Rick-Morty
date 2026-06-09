//
//  ImageCache.swift
//  R&M
//
//  Created by Narciso Meza on 09/06/26.
//

import UIKit

final class ImageCache {
	static let shared = ImageCache()
	
	private let memory = NSCache<NSString, UIImage>()
	private let diskURL: URL = {
		FileManager.default
			.urls(for: .cachesDirectory, in: .userDomainMask)[0]
			.appendingPathComponent("ImageCache", isDirectory: true)
	}()
	
	private init() {
		self.memory.countLimit = 100
		self.memory.totalCostLimit = 50 * 1024 * 1024 // 50 MB
		try? FileManager.default.createDirectory(at: diskURL, withIntermediateDirectories: true)
	}
	
	func image(for url: URL) -> UIImage? {
		let key = self.cacheKey(for: url)
		
		if let cached = self.memory.object(forKey: key as NSString) {
			return cached
		}
		
		let fileURL = self.diskURL.appendingPathComponent(key)
		guard
			let data = try? Data(contentsOf: fileURL),
			let image = UIImage(data: data)
		else { return nil }
		
		self.memory.setObject(image, forKey: key as NSString)
		return image
	}
	
	func store(_ image: UIImage, for url: URL) {
		let key = self.cacheKey(for: url)
		self.memory.setObject(image, forKey: key as NSString)
		
		let fileURL = self.diskURL.appendingPathComponent(key)
		if let data = image.jpegData(compressionQuality: 0.9) {
			try? data.write(to: fileURL)
		}
	}
	
	private func cacheKey(for url: URL) -> String {
		url.absoluteString
			.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? url.lastPathComponent
	}
}
