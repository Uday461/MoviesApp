//
//  MovieModel.swift
//  Movies App (Inshorts)
//
//  Created by Banavath UdayKiran Naik on 09/05/25.
//
import Foundation

struct Movies: Codable {
    var results: [MovieModel]
    
    enum CodingKeys: String, CodingKey {
      case results
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.results = try container.decode([MovieModel].self, forKey: .results)
    }
}

struct MovieModel: Codable {
    var title: String?
    var description: String?
    var posterPath: String?
    var rating: Double?
    var movieId: Int?
    
    enum CodingKeys: String, CodingKey {
        case bookMarked
        case title
        case description = "overview"
        case posterPath = "poster_path"
        case rating = "vote_average"
        case movieId = "id"
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(self.title, forKey: .title)
        try container.encodeIfPresent(self.description, forKey: .description)
        try container.encodeIfPresent(self.posterPath, forKey: .posterPath)
        try container.encodeIfPresent(self.rating, forKey: .rating)
        try container.encodeIfPresent(self.movieId, forKey: .movieId)
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.title = try container.decodeIfPresent(String.self, forKey: .title)
        self.description = try container.decodeIfPresent(String.self, forKey: .description)
        self.posterPath = try container.decodeIfPresent(String.self, forKey: .posterPath)
        self.rating = try container.decodeIfPresent(Double.self, forKey: .rating)
        self.movieId = try container.decodeIfPresent(Int.self, forKey: .movieId)
    }
}
