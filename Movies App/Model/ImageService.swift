//
//  ImageService.swift
//  Movies App (Inshorts)
//
//  Created by Banavath UdayKiran Naik on 11/05/25.
//

import Foundation
import CoreData
import UIKit

protocol ImageServiceProtocol {
    func fetchImage(for movie: Movie, completionHandler: @escaping(Result<UIImage, Error>) -> Void)
}

private class CacheEntry {
    let uiImage: UIImage
    let date: Date
    init(uiImage: UIImage, date: Date) {
        self.uiImage = uiImage
        self.date = date
    }
}

class ImageService: ImageServiceProtocol {
    private let networkManager: NetworkManagerProtocol
    private let cache = NSCache<NSString, CacheEntry>()
    private let cacheTimeLimit = 5 * 60  // 5 minutes
    
    init(networkManager: NetworkManagerProtocol) {
        self.networkManager = NetworkManager()
    }
    
    func fetchImage(for movie: Movie, completionHandler: @escaping (Result<UIImage, any Error>) -> Void) {
        guard let movieName = movie.title else {
            print("Movie Title is nil")
            completionHandler(.failure(NSError(domain: "Movie Title is nil", code: 0)))
            return
        }
        
        //Fetch from NSCache
        if let cachEntry = cache.object(forKey: NSString(string: movieName)) {
            if Date().timeIntervalSince(cachEntry.date) < TimeInterval(cacheTimeLimit) {
                print("Image Fetched From Cache !!")
                completionHandler(.success(cachEntry.uiImage))
                return
            } else {
                cache.removeObject(forKey: NSString(string: movieName))
                print("Image Removed From Cache as it exceeded Cache Expiry Interval. Image will be fetched disk/server")
            }
        }
        
        //Fetch from Persistance storage
        var movieImages = fetchImages()
        movieImages = movieImages.filter {$0.movieTitle == movieName}
        
        if !movieImages.isEmpty, let imageData = movieImages.first?.image as Data?, let image = UIImage(data: imageData) {
            print("Image Fetched from Disk Storage")
            cache.setObject(CacheEntry(uiImage: image, date: Date()), forKey: NSString(string: movie.title ?? ""))
            completionHandler(.success(image))
            return
        }
        
        //Download And Cache and Persist Image to DataBase
        downloadImageAndSave(movie: movie, completionHandler: completionHandler)
    }
    
    private func fetchImages() -> [MovieImage] {
        return CoreDataManager.sharedInstance.fetchData(ofType: MovieImage.self)
    }
    
    private func downloadImageAndSave(movie: Movie, completionHandler: @escaping (Result<UIImage, Error>) -> Void) {
        guard let posterPath = movie.posterPath else {
            completionHandler(.failure(NSError(domain: "No Image Path", code: 0)))
            return
        }
        
        self.networkManager.fetchData(networkService: .downloadImage(imagePath: posterPath)) { result in
            switch result {
            case .success(let data):
                self.saveImage(movie: movie, data: data)
                if let image = UIImage(data: data) {
                    completionHandler(.success(image))
                } else {
                    completionHandler(.failure(NSError(domain: "Image cannot converted from Data to UIImage", code: 0)))
                }
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
    }
    
    func saveImage(movie: Movie, data: Data) {
        guard let uiImage = UIImage(data: data) else {
            return
        }
        
        //Cache Image using NSCaching
        cache.setObject(CacheEntry(uiImage: uiImage, date: Date()), forKey: NSString(string: movie.title ?? ""))
        
        //Persist Image
        let context = CoreDataManager.sharedInstance.context
        let image = MovieImage(context: context)
        image.movieTitle = movie.title ?? ""
        image.image = data
        
        CoreDataManager.sharedInstance.save()
    }
}

