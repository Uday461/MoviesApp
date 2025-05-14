//
//  MovieCell.swift
//  Movies App (Inshorts)
//
//  Created by Banavath UdayKiran Naik on 10/05/25.
//

import UIKit
import Combine

class MovieCollectionViewCell: UICollectionViewCell {
    static let identifier = "MovieCollectionViewCell"
    private var cancellables: Set<AnyCancellable> = []
    private var movieVM: MoviesViewModelProtocol? = nil
    
    private let movieImageView: UIImageView = {
        let movieImageView = UIImageView()
        movieImageView.clipsToBounds = true
        movieImageView.layer.cornerRadius = 8
        movieImageView.contentMode = .scaleAspectFill
        return movieImageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        contentView.addSubview(movieImageView)
        movieImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            movieImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            movieImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            movieImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            movieImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
    
    func configure(movie: Movie, viewModel: MoviesViewModelProtocol) {
        self.movieVM = viewModel
        self.movieVM?.fetchMovieImage(movie: movie, completionHandler: { [weak self] result in
            switch(result) {
            case .success(let image):
                DispatchQueue.main.async {
                    self?.movieImageView.image = image
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.movieImageView.image = UIImage(systemName: "film")
                }
            }
        })
    }
}
