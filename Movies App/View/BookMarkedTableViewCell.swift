//
//  BookMarkedTableViewCell.swift
//  Movies App (Inshorts)
//
//  Created by Banavath UdayKiran Naik on 10/05/25.
//

import UIKit

class BookMarkedTableViewCell: UITableViewCell {
    static let identifier = "BookMarkedTableViewCell"
    private var movieVM: MoviesViewModelProtocol? = nil
    
    private let movieImageView: UIImageView = {
        let movieImageView = UIImageView()
        movieImageView.clipsToBounds = true
        movieImageView.layer.cornerRadius = 8
        movieImageView.contentMode = .scaleAspectFill
        return movieImageView
    }()
    
    private let movieTitleLabel: UILabel = {
        let movieTitleLabel = UILabel()
        movieTitleLabel.font = .systemFont(ofSize: 17, weight: .medium)
        movieTitleLabel.textColor = .white
        movieTitleLabel.numberOfLines = 1
        return movieTitleLabel
    }()
    
    private let movieDescriptionLabel: UILabel = {
        let movieDescription = UILabel()
        movieDescription.font = .systemFont(ofSize: 12, weight: .semibold)
        movieDescription.textColor = .white
        movieDescription.numberOfLines = 5
        return movieDescription
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        contentView.addSubview(movieImageView)
        contentView.addSubview(movieTitleLabel)
        contentView.addSubview(movieDescriptionLabel)
        
        movieImageView.translatesAutoresizingMaskIntoConstraints = false
        movieTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        movieDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Set up constraints
        NSLayoutConstraint.activate([
            // movieImageView constraints
            movieImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            movieImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            movieImageView.widthAnchor.constraint(equalToConstant: 80),
            movieImageView.heightAnchor.constraint(equalToConstant: 120),
            
            // movieTitleLabel constraints
            movieTitleLabel.leadingAnchor.constraint(equalTo: movieImageView.trailingAnchor, constant: 15),
            movieTitleLabel.topAnchor.constraint(equalTo: movieImageView.topAnchor),
            movieTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            
            // movieDescriptionLabel constraints
            movieDescriptionLabel.leadingAnchor.constraint(equalTo: movieTitleLabel.leadingAnchor),
            movieDescriptionLabel.topAnchor.constraint(equalTo: movieTitleLabel.bottomAnchor, constant: 5),
            movieDescriptionLabel.trailingAnchor.constraint(equalTo: movieTitleLabel.trailingAnchor),
            
        ])
        
        contentView.backgroundColor = .black
    }
    
    func configure(movie: Movie, viewModel: MoviesViewModelProtocol) {
        self.movieVM = viewModel
        movieTitleLabel.text = movie.title
        movieDescriptionLabel.text = movie.movieDescription
        
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
