//
//  RecipeAppTests.swift
//  RecipeAppTests
//
//  Created by Suraj Raju Dhopati on 1/25/25.
//

import XCTest
@testable import RecipeApp

final class RecipeServiceTests: XCTestCase {
/* Uncomment below and check RecipeService when UnitTesting */
//    func testFetchRecipesSuccess() async throws {
//        let service = RecipeService(url: URL(string: "https://d3jbb8n5wk0qxi.cloudfront.net/recipes.json")!)
//        let recipes = try await service.fetchRecipes()
//        XCTAssertFalse(recipes.isEmpty, "Expected recipes to be returned from a valid endpoint")
//    }
//
//    func testFetchRecipesEmpty() async {
//        let service = RecipeService(url: URL(string: "https://d3jbb8n5wk0qxi.cloudfront.net/recipes-empty.json")!)
//        do {
//            let recipes = try await service.fetchRecipes()
//            XCTAssertTrue(recipes.isEmpty, "Expected no recipes from an empty endpoint")
//        } catch {
//            XCTFail("Expected empty recipes, but received an error: \(error)")
//        }
//    }
//    
//    func testFetchRecipesMalformed() async {
//        let service = RecipeService(url: URL(string: "https://d3jbb8n5wk0qxi.cloudfront.net/recipes-malformed.json")!)
//        do {
//            _ = try await service.fetchRecipes()
//            XCTFail("Expected error for malformed data, but fetch succeeded")
//        } catch {
//
//        }
//    }
}

final class ImageCacheTests: XCTestCase {
    func testImageCaching() async {
        guard let url = URL(string: "https://dummyimage.com/150x150/000/fff.png&text=test") else {
            XCTFail("Invalid URL")
            return
        }
        
        let cache = ImageCache.shared
        let image1 = await cache.getImage(for: url)
        
        if image1 == nil {
            print("Failed to load image for URL: \(url)")
        }
        XCTAssertNotNil(image1, "Image should load successfully on first request")
        
        let image2 = await cache.getImage(for: url)
        XCTAssertNotNil(image2, "Image should be returned from cache on subsequent requests")
        
        if let img1 = image1, let img2 = image2,
           let data1 = img1.pngData(), let data2 = img2.pngData() {
            XCTAssertEqual(data1, data2, "Cached image should be identical to the originally loaded image")
        }
    }
}

protocol ImageFetching {
    func fetchImage(from url: URL) async throws -> UIImage
}

final class URLSessionImageFetcher: ImageFetching {
    func fetchImage(from url: URL) async throws -> UIImage {
        let (data, _) = try await URLSession.shared.data(from: url)
        guard let image = UIImage(data: data) else {
            throw URLError(.cannotDecodeContentData)
        }
        return image
    }
}

final class MockImageFetcher: ImageFetching {
    func fetchImage(from url: URL) async throws -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 150, height: 150)
        UIGraphicsBeginImageContextWithOptions(rect.size, true, 0)
        UIColor.red.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
}
