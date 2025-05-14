//
//  NetworkManager.swift
//  Movies App (Inshorts)
//
//  Created by Banavath UdayKiran Naik on 09/05/25.
//
import Foundation

protocol NetworkManagerProtocol {
    func fetchData(networkService: NetworkService, completionHandler: @escaping(Result<Data, Error>) -> Void)
}

enum NetworkService {
    case fetchTrendingMovies(page: Int)
    case fetchNowPlayingMovies(page: Int)
    case downloadImage(imagePath: String)
    case fetchMovieBySearch(movieName: String)
    
    func fetchUrl() -> String {
        switch self {
        case .fetchNowPlayingMovies(let page):
            return "https://api.themoviedb.org/3/movie/now_playing?page=\(page)"
        case .fetchTrendingMovies(let page):
            return "https://api.themoviedb.org/3/trending/movie/day?page=\(page)"
        case .downloadImage(let imagePath):
            return "https://image.tmdb.org/t/p/w500\(imagePath)"
        case .fetchMovieBySearch(let movieName):
            return "https://api.themoviedb.org/3/search/movie?query=\(movieName)&page=1"
        }
    }
}

class NetworkManager: NetworkManagerProtocol {
    func fetchData(networkService: NetworkService, completionHandler: @escaping(Result<Data, Error>) -> Void) {
        guard let url = URL(string: networkService.fetchUrl()) else {
            print("Error while creating  URL")
            return
        }
        
        guard let request = networkRequest(url: url) else {
            print("Error while creating Network Request")
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                completionHandler(.success(data))
            } else if let error = error {
                completionHandler(.failure(error))
            }
        }.resume()
    }
    
    private func networkRequest(url: URL) -> URLRequest? {
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            print("Error in URL Component Building")
            return nil
        }
        
        let queryItems: [URLQueryItem] = [
            URLQueryItem(name: "language", value: "en-US"),
        ]
        components.queryItems = components.queryItems.map { $0 + queryItems } ?? queryItems
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = [
            "accept": "application/json",
            "Authorization": "Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJkOTc3MmFmMzBlMTFhMDZlYTc2MzYxNWJkZWY0NmY4YSIsIm5iZiI6MTc0NzI0NDM5My43NzIsInN1YiI6IjY4MjRkNTY5MzcxYWFkNGMzZjJkMjcxNyIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.BpmhB3QKjPi9VHGA4xTpD65aCQuc_1DGu5ZzkN-QwKM"
        ]
        
        return request
    }
}
