//
//  GIFImageView.swift
//  R&M
//
//  Created by Narciso Meza on 09/06/26.
//

import SwiftUI
import UIKit
import ImageIO

struct GIFImageView: UIViewRepresentable {
    let name: String

    func makeUIView(context: Context) -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
		imageView.image = UIImage.gifImage(named: self.name)
        return imageView
    }

    func updateUIView(_ uiView: UIImageView, context: Context) {}
}

private extension UIImage {
    static func gifImage(named name: String) -> UIImage? {
        guard
            let url = Bundle.main.url(forResource: name, withExtension: "gif"),
            let data = try? Data(contentsOf: url)
        else { return nil }

        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else { return nil }

        let count = CGImageSourceGetCount(source)
        var images: [UIImage] = []
        var totalDuration = 0.0

        for i in 0..<count {
            guard let cgImage = CGImageSourceCreateImageAtIndex(source, i, nil) else { continue }
            let delay = frameDelay(source: source, index: i)
            totalDuration += delay
            images.append(UIImage(cgImage: cgImage))
        }

        return images.count == 1
            ? images.first
            : UIImage.animatedImage(with: images, duration: totalDuration)
    }

    static func frameDelay(source: CGImageSource, index: Int) -> Double {
        let defaultDelay = 0.1
        guard
            let props = CGImageSourceCopyPropertiesAtIndex(source, index, nil) as? [CFString: Any],
            let gifProps = props[kCGImagePropertyGIFDictionary] as? [CFString: Any]
        else { return defaultDelay }

        if let delay = gifProps[kCGImagePropertyGIFUnclampedDelayTime] as? Double, delay > 0 {
            return delay
        }
        if let delay = gifProps[kCGImagePropertyGIFDelayTime] as? Double, delay > 0 {
            return delay
        }
        return defaultDelay
    }
}
