//
//  CacheManager.swift
//  BuddyBuddy
//
//  Created by 아라 on 12/15/24.
//

import UIKit

final class CacheManager {
    static let shared = CacheManager()
    
    @Dependency(NetworkProtocol.self)
    private var networkService: NetworkProtocol
    private let fileManager = FileManager.default
    private let cache = NSCache<NSString, UIImage>()
    private let diskPath: String = {
        guard let path = NSSearchPathForDirectoriesInDomains(
            .cachesDirectory,
            .userDomainMask,
            true
        ).first else {
            return ""
        }
        return path
    }()
    
    private init() { }
    
    func loadImg(urlPath: String) async throws -> UIImage {
        let path = urlPath.replacingOccurrences(
            of: "/",
            with: ""
        )
        
        // Memory Cache
        if let image = cache.object(forKey: urlPath as NSString) {
            return image
        }
        
        // Disk Cache
        var filePath = URL(fileURLWithPath: diskPath)
        filePath.appendPathComponent(path)
        
        if fileManager.fileExists(atPath: filePath.path) {
            if let imageData = try? Data(contentsOf: filePath),
               let image = UIImage(data: imageData) {
                
                cache.setObject(
                    image,
                    forKey: urlPath as NSString
                )
                
                return image
            } else {
                throw NSError(
                    domain: "disk cache image nil",
                    code: 1
                )
            }
        } else {
            let image = try await imageDownload(urlPath)
            
            imgCaching(image, urlPath: path)
            return image
        }
    }
    
    private func imageDownload(_ urlPath: String) async throws -> UIImage {
        let router = ImageRouter.loadImage(path: urlPath)
        let data = try await networkService.downloadImage(router: router)
        
        guard let image = UIImage(data: data) else {
            throw NSError(
                domain: "image convert error",
                code: 2
            )
        }
        return image
    }
    
    private func imgCaching(_ image: UIImage, urlPath: String) {
        cache.setObject(
            image,
            forKey: urlPath as NSString
        )
        
        var filePath = URL(fileURLWithPath: diskPath)
        filePath.appendPathComponent(urlPath)
        
        if let data = image.jpegData(compressionQuality: 0.5) {
            do {
                try data.write(to: filePath)
            } catch {
                print("file not save")
            }
        }
    }
}
