//
//  UIImageView+.swift
//  BuddyBuddy
//
//  Created by 아라 on 12/15/24.
//

import UIKit

extension UIImageView {
    func loadImage(with path: String?, defaultImg: UIImage? = nil) {
        guard let path else {
            self.image = defaultImg
            return
        }
        
        Task {
            self.image = try await CacheManager.shared.loadImg(urlPath: path)
        }
    }
}
