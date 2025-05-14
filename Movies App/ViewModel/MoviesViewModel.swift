//
//  MoviesViewModel.swift
//  Movies App (Inshorts)
//
//  Created by Banavath UdayKiran Naik on 09/05/25.
//
import Foundation
import UIKit

protocol MoviesViewModelProtocol: AnyObject {
    var nowPlayingMoviesUpdated: (([Movie]) -> Void)? { get set }
    var trendingMoviesUpdated: (([Movie]) -> Void)? { get set }
    var searchResultsUpdated: (([Movie]) -> Void)? { get set }
    var errorMessageUpdated: ((String) -> Void)? { get set }

    func fetchNowPlayingMovies(page: Int)
    func fetchTrendingMovies(page: Int)
    func searchMovies()
    func updateSearchQuery(with query: String)
    func fetchMovieImage(movie: Movie, completionHandler: @escaping(Result<UIImage, Error>) -> Void)
    func fetchBookMarkedMovies() -> [Movie]
    func bookMarkMovie(movie: Movie)
    func fetchMovieById(movieId: Int) -> Movie?
}


class MoviesViewModel: MoviesViewModelProtocol {
    var nowPlayingMoviesUpdated: (([Movie]) -> Void)? = nil
    var trendingMoviesUpdated: (([Movie]) -> Void)? = nil
    var searchResultsUpdated: (([Movie]) -> Void)? = nil
    var errorMessageUpdated: ((String) -> Void)? = nil
    
    private var searchQuery: String = ""
    private var movieImage: UIImage? = nil
    private var workItem: DispatchWorkItem? = nil
        
    var movieManager: MovieManager
    
    public init() {
        self.movieManager = MovieManager(movieService: MovieService(), imageService: ImageService())
    }
    
    //Property Observers: ViewModel storing UI state
    private var nowPlayingMovies: [Movie] = [] {
        didSet {
            nowPlayingMoviesUpdated?(nowPlayingMovies)
        }
    }
    
    private var trendingMovies: [Movie] = [] {
        didSet {
            trendingMoviesUpdated?(trendingMovies)
        }
    }
    
    private var searchResults: [Movie] = [] {
        didSet {
            searchResultsUpdated?(searchResults)
        }
    }
    
    private var errorMessage = "" {
        didSet {
            errorMessageUpdated?(errorMessage)
        }
    }
        
    func fetchNowPlayingMovies(page: Int) {
        movieManager.fetchMovies(movieType: .nowPlaying, page: page) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let movies):
                if page == 1 {
                    self.nowPlayingMovies = movies
                } else {
                    let newMovies = movies.filter { newMovie in
                        !self.nowPlayingMovies.contains { $0.title == newMovie.title }
                    }
                    self.nowPlayingMovies.append(contentsOf: newMovies)
                }
            case .failure(let error):
                self.errorMessage = error.localizedDescription
                if page == 1 {
                    self.nowPlayingMovies = movieManager.getStoredMovies(movieType: .nowPlaying)
                }
            }
        }
    }
    
    func fetchTrendingMovies(page: Int) {
        movieManager.fetchMovies(movieType: .trending, page: page) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let movies):
                if page == 1 {
                    self.trendingMovies = movies
                } else {
                    let newMovies = movies.filter { newMovie in
                        !self.trendingMovies.contains { $0.title == newMovie.title }
                    }
                    self.trendingMovies.append(contentsOf: newMovies)
                }
            case .failure(let error):
                self.errorMessage = error.localizedDescription
                if page == 1 {
                    self.trendingMovies = movieManager.getStoredMovies(movieType: .trending)
                }
            }
        }
    }
    
    
    func searchMovies() {
        workItem?.cancel()
        
        guard !searchQuery.isEmpty else {
            print("Search Query is Empty Hence no network Call will be made to fetch movie!!")
            searchResults = []
            return
        }
        
        let networkItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            self.movieManager.searchMovie(for: self.searchQuery) { [weak self] result in
                guard let self = self else { return }
                switch(result) {
                case .success(let movies):
                    searchResults = movies
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
        
        workItem = networkItem
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 1, execute: networkItem)
    }
    
    func updateSearchQuery(with query: String) {
        searchQuery = query
        searchMovies()
    }
    
    func fetchMovieImage(movie: Movie, completionHandler: @escaping(Result<UIImage, Error>) -> Void) {
        movieManager.fetchImage(for: movie, completionHandler: completionHandler)
    }
    
    func fetchBookMarkedMovies() -> [Movie] {
        return movieManager.getBookMarkedMovies()
    }
    
    func bookMarkMovie(movie: Movie) {
        movieManager.bookMarkMovie(movie: movie)
    }
    
    func fetchMovieById(movieId: Int) -> Movie? {
        let movies = movieManager.getStoredMovies(movieType: .nowPlaying) + movieManager.getStoredMovies(movieType: .trending)
        
        if let movie = movies.first(where: { $0.movieId == movieId }) {
            return movie
        }
        
        return nil
    }
}
