//
//  MovieManager.swift
//  Movies App (Inshorts)
//
//  Created by Banavath UdayKiran Naik on 11/05/25.
//

import UIKit
import Foundation

class MovieManager {
    private let movieService: MovieServiceProtocol
    private let imageService: ImageServiceProtocol
    
    init(movieService: MovieServiceProtocol, imageService: ImageServiceProtocol) {
        self.movieService = movieService
        self.imageService = imageService
    }
    
    func fetchMovies(movieType: MovieType, page: Int, completionHandler: @escaping (Result<[Movie], any Error>) -> Void) {
        movieService.fetchMovies(movieType: movieType, page: page, completionHandler: completionHandler)
    }
    
    func fetchImage(for movie: Movie, completionHandler: @escaping(Result<UIImage, Error>) -> Void) {
        imageService.fetchImage(for: movie, completionHandler: completionHandler)
    }
    
    func searchMovie(for movieName: String, completionHandler: @escaping(Result<[Movie], any Error>) -> Void) {
        movieService.searchMovie(movieName: movieName, completionHandler: completionHandler)
    }
    
    func getStoredMovies(movieType: MovieType) -> [Movie] {
        var movies = movieService.getStoredMovies()
        movies = movies.filter({ movie in
            return movie.listType == movieType.rawValue
        })
        return movies
    }
    
    func getBookMarkedMovies() -> [Movie] {
        return movieService.getBookmarkedMovies()
    }
    
    func bookMarkMovie(movie: Movie) {
        movieService.bookMarkMovie(movie: movie)
    }
}
