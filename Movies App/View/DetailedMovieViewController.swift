//
//  DetailedMovieViewController.swift
//  Movies App (Inshorts)
//
//  Created by Banavath UdayKiran Naik on 11/05/25.
//

import UIKit
//TODO: -
//Code Clean Up: Use viewmodels for storing UI state & Breaking MovieManager class into different classes.
//Pagination
// Detailed VC
//BookMarked VC
//

class DetailedMovieViewController: UIViewController {
    var movie: Movie? = nil
    var movieVM: MoviesViewModelProtocol? = nil
    
    init(viewModel: MoviesViewModelProtocol) {
        self.movieVM = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let movieImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .white
        label.numberOfLines = 0
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16)
        label.textColor = .white
        label.numberOfLines = 0
        return label
    }()
    
    private let ratingLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textColor = .white
        return label
    }()
    
    private let bookmarkButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .white
        return button
    }()
    
    private let shareButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .white
        button.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
        return button
    }()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupUI()
        configureView()
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        view.backgroundColor = .black
        
        // Add subviews
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(movieImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(ratingLabel)
        contentView.addSubview(bookmarkButton)
        contentView.addSubview(shareButton)
        
        // Set up constraints
        setupConstraints()
        
        // Set up button action
        bookmarkButton.addTarget(self, action: #selector(bookmarkButtonTapped), for: .touchUpInside)
        shareButton.addTarget(self, action: #selector(shareButtonTapped), for: .touchUpInside)
    }
    
    private func setupConstraints() {
        // ScrollView constraints
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
        
        // ContentView constraints
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        // ImageView constraints
        NSLayoutConstraint.activate([
            movieImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            movieImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            movieImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            movieImageView.heightAnchor.constraint(equalToConstant: 500)
        ])
        
        // TitleLabel constraints
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: movieImageView.bottomAnchor, constant: 15),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
        
        // DescriptionLabel constraints
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
        
        // RatingLabel constraints
        NSLayoutConstraint.activate([
            ratingLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 10),
            ratingLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            ratingLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20) // Pin to bottom
        ])
        
        // BookmarkButton constraints
        NSLayoutConstraint.activate([
            bookmarkButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 10),
            bookmarkButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            bookmarkButton.leadingAnchor.constraint(greaterThanOrEqualTo: ratingLabel.trailingAnchor, constant: 10), // Add this line
            bookmarkButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
        
        NSLayoutConstraint.activate([
            shareButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 10),
            shareButton.trailingAnchor.constraint(equalTo: bookmarkButton.leadingAnchor, constant: -20),
            shareButton.leadingAnchor.constraint(greaterThanOrEqualTo: ratingLabel.trailingAnchor, constant: 10),
            shareButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
        
        NSLayoutConstraint.activate([
            contentView.bottomAnchor.constraint(equalTo: ratingLabel.bottomAnchor, constant: 20),
        ])
    }
    
    // MARK: - Configuration
    
    private func configureView() {
        if let movie = movie {
            titleLabel.text = movie.title
            descriptionLabel.text = movie.movieDescription
            ratingLabel.text = "Rating: \(movie.rating)"
            
            movieVM?.fetchMovieImage(movie: movie, completionHandler: { result in
                switch result {
                case .success(let image):
                    self.movieImageView.image = image
                case .failure(let error):
                    self.movieImageView.image = UIImage(systemName: "film")
                }
            })
            
            let bookmarkImageName = movie.bookMarked ? "bookmark.fill" : "bookmark"
            bookmarkButton.setImage(UIImage(systemName: bookmarkImageName), for: .normal)
        }
    }
    
    // MARK: - Actions
    @objc func bookmarkButtonTapped(_ sender: UIButton) {
        guard let movie = movie else {
            print("Movie object is nil")
            return
        }
        
        movieVM?.bookMarkMovie(movie: movie)
        
        let bookmarkImageName = movie.bookMarked ? "bookmark.fill" : "bookmark"
        sender.setImage(UIImage(systemName: bookmarkImageName), for: .normal)
        
        if movie.bookMarked {
            print("Movie bookmarked")
        } else {
            print("Movie removed from bookmarks")
        }
    }
    
    @objc func shareButtonTapped(_ sender: UIButton) {
        guard let movie = movie else {
            print("Movie object/ Movie Id is nil")
            return
        }

        let deepLink = "moviesapp://movie/\(movie.movieId)"
        
        let shareText = "Check out this movie at: \(deepLink)"
        
        let activityViewController = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
        present(activityViewController, animated: true)
    }
}
