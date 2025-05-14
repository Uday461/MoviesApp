//
//  MovieService.swift
//  Movies App (Inshorts)
//
//  Created by Banavath UdayKiran Naik on 11/05/25.
//

import Foundation
import CoreData
import UIKit

enum MovieType: String {
   case nowPlaying
   case trending
}

protocol MovieServiceProtocol {
    func fetchMovies(movieType: MovieType, page: Int, completionHandler: @escaping(Result<[Movie], Error>) -> Void)
    func getStoredMovies() -> [Movie]
    func getBookmarkedMovies() -> [Movie]
    func bookMarkMovie(movie: Movie)
    func searchMovie(movieName: String, completionHandler: @escaping(Result<[Movie], Error>) -> Void)
}

class MovieService: MovieServiceProtocol {
    var networkManager: NetworkManagerProtocol
    
    init() {
        self.networkManager = NetworkManager()
    }
    
    func fetchMovies(movieType: MovieType, page: Int, completionHandler: @escaping (Result<[Movie], any Error>) -> Void) {
        print("Movies Sync Initiated for Moive Type: \(movieType.rawValue)...!!!")
        
        self.networkManager.fetchData(networkService: fetchNetworkService(movieType: movieType, page: page)) { [weak self] result in
            guard let self = self else { return }
            switch(result) {
            case .success(let data):
                let movieModelArray = self.parseMovie(data: data)
                self.persistMovie(movieModelArray, movieType: movieType)
                var movies = self.getStoredMovies()
                movies = movies.filter {$0.listType == movieType.rawValue}
                completionHandler(.success(movies))
                
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
    }
    
    func searchMovie(movieName: String, completionHandler: @escaping(Result<[Movie], Error>) -> Void) {
        print("Fetching Movies By Search, Movie Name: \(movieName)")
        self.networkManager.fetchData(networkService: .fetchMovieBySearch(movieName: movieName)) {  [weak self] result in
            guard let self = self else { return }
            switch(result) {
            case .success(let data):
                let movieModelArray = self.parseMovie(data: data)
                completionHandler(.success(getMovieArray(movieModelArray: movieModelArray)))
            case .failure(let error):
                completionHandler(.failure(error))
            }

        }
    }
    
    func getStoredMovies() -> [Movie] {
        return CoreDataManager.sharedInstance.fetchData(ofType: Movie.self)
    }
    
    func getBookmarkedMovies() -> [Movie] {
        return getStoredMovies().filter {$0.bookMarked}
    }
    
    private func parseMovie(data: Data) -> [MovieModel]{
        guard let movies = try? JSONDecoder().decode(Movies.self, from: data) else {
            print("Error in JSON Decoding !!")
            return []
        }
        
        var movieArray = movies.results
        return movieArray
    }
    
    private func getMovieArray(movieModelArray: [MovieModel]) -> [Movie] {
        var movieArray: [Movie] = []
        let context = CoreDataManager.sharedInstance.context
        for movieModel in movieModelArray {
            let movie = Movie(context: context)
            movie.title = movieModel.title
            movie.movieDescription = movieModel.description
            movie.posterPath = movieModel.posterPath
            movie.rating = movieModel.rating ?? 0
            movie.bookMarked = false
            movie.listType = "searchedMovie"
            movie.movieId = Int32(movieModel.movieId ?? 0)
            movieArray.append(movie)
        }
        return movieArray
    }
    
    private func filterNewMovies(movies: [MovieModel]) -> [MovieModel] {
        let moviesFromStorage = getStoredMovies()
        var moviesArray = movies
        
        if !moviesFromStorage.isEmpty {
            let movieIdsFromStorage = Set(moviesFromStorage.map(\.title))
            moviesArray = moviesArray.filter { !movieIdsFromStorage.contains($0.title) }
        }
        
        return moviesArray
    }
    
    private func persistMovie(_ movies: [MovieModel], movieType: MovieType) {
        let movieArray = filterNewMovies(movies: movies)
        
        if movieArray.isEmpty {
            print("No New Movies Fetched, hence avoiding data persistence !! (To avoid Duplicate Data)")
            return
        }
        
        let context = CoreDataManager.sharedInstance.context
        for movieModel in movies {
            let movie = Movie(context: context)
            movie.title = movieModel.title
            movie.movieDescription = movieModel.description
            movie.posterPath = movieModel.posterPath
            movie.rating = movieModel.rating ?? 0
            movie.bookMarked = false
            movie.listType = movieType.rawValue
            movie.movieId = Int32(movieModel.movieId ?? 0)
        }
        CoreDataManager.sharedInstance.save()
    }
    
    private func fetchNetworkService(movieType: MovieType, page: Int) -> NetworkService {
        switch(movieType) {
        case .nowPlaying: return .fetchNowPlayingMovies(page: page)
        case .trending: return .fetchTrendingMovies(page: page)
       }
    }
    
    func bookMarkMovie(movie: Movie) {
       var movies = getStoredMovies()
       if let index = movies.firstIndex(where: { $0.title == movie.title }) {
           movies[index].bookMarked.toggle()
        } 
        CoreDataManager.sharedInstance.save()
    }
}
