import UIKit

final class ImageCache {
    static let shared = ImageCache()
    private init() {
        createCacheDirectoryIfNeeded()
    }

    private var cache = NSCache<NSURL, UIImage>()

    private var cacheDirectory: URL {
        let fileManager = FileManager.default
        let cachesURL = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        return cachesURL.appendingPathComponent("ImageCache", isDirectory: true)
    }

    private func createCacheDirectoryIfNeeded() {
        let fileManager = FileManager.default
        let directory = cacheDirectory
        if !fileManager.fileExists(atPath: directory.path) {
            do {
                try fileManager.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Failed to create image cache directory: \(error)")
            }
        }
    }

    private func diskCacheURL(for url: URL) -> URL {
        let fileName = String(url.absoluteString.hashValue)
        return cacheDirectory.appendingPathComponent(fileName)
    }

    func getImage(for url: URL) async -> UIImage? {
        if let cachedImage = cache.object(forKey: url as NSURL) {
            return cachedImage
        }
        
        let diskURL = diskCacheURL(for: url)
        if FileManager.default.fileExists(atPath: diskURL.path),
           let data = try? Data(contentsOf: diskURL),
           let image = UIImage(data: data) {
            cache.setObject(image, forKey: url as NSURL)
            return image
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let image = UIImage(data: data) else {
                print("Failed to create image from data for URL: \(url)")
                return nil
            }
            cache.setObject(image, forKey: url as NSURL)
            do {
                try data.write(to: diskURL)
            } catch {
                print("Error writing image to disk: \(error)")
            }
            return image
        } catch {
            print("Error fetching image from URL: \(url) - \(error)")
            return nil
        }
    }

}
