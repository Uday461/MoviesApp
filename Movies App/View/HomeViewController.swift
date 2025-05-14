//
//  HomeViewController.swift
//  Movies App (Inshorts)
//
//  Created by Banavath UdayKiran Naik on 10/05/25.
//
import UIKit

private enum Section: Int, CaseIterable {
    case trending
    case nowPlaying
    case searchResults
    
    var title: String {
        switch self {
        case .trending:
            return "Trending"
        case .nowPlaying:
            return "Now Playing"
        case .searchResults:
            return "Search Results"
        }
    }
}

class HomeViewController: UIViewController {
    var nowPlayingMovies: [Movie] = []
    var trendingMovies: [Movie] = []
    var searchResults: [Movie] = []
    private var collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewLayout())
    private let movieVM: MoviesViewModelProtocol
    private let searchController = UISearchController(searchResultsController: nil)
    private var currentPageNowPlaying = 1
    private var currentPageTrending = 1
    private var isFetchingNowPlaying = false
    private var isFetchingTrending = false
    private var activityIndicator = UIActivityIndicatorView(style: .large)
    
    private let sectionHeaders = ["Trending", "Now Playing"]
    
    init(viewModel: MoviesViewModelProtocol) {
        self.movieVM = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        activityIndicator.color = .lightGray
        setupSearchController()
        setupViewModelBindings()
        setupCollectionView()
        loadMovies()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchController.searchBar.searchTextField.textColor = .white
    }
    
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Movies"
        searchController.searchBar.tintColor = .white
        
        let textField = searchController.searchBar.searchTextField
        textField.textColor = .white
        textField.tintColor = .white
        textField.backgroundColor = UIColor(white: 1.0, alpha: 0.1)
        
        let placeholderAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.lightGray
        ]
        textField.attributedPlaceholder = NSAttributedString(
            string: "Search Movies",
            attributes: placeholderAttributes
        )
        
        if let leftView = textField.leftView as? UIImageView {
            leftView.tintColor = .white
        }
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
        definesPresentationContext = true
    }
    
    private func setupCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.backgroundColor = .systemBackground
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(MovieCollectionViewCell.self, forCellWithReuseIdentifier: MovieCollectionViewCell.identifier)
        collectionView.register(TitleHeaderView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: TitleHeaderView.identifier)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .black
        view.addSubview(collectionView)
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            activityIndicator.widthAnchor.constraint(equalToConstant: 80),
            activityIndicator.heightAnchor.constraint(equalToConstant: 80)
        ])
    }
    
    private func setupViewModelBindings() {
        movieVM.nowPlayingMoviesUpdated = { [weak self] movies in
            guard let self = self else { return }
            self.nowPlayingMovies = movies
            self.isFetchingNowPlaying = false
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                self.collectionView.reloadData()
            }
        }
        
        movieVM.trendingMoviesUpdated = { [weak self] movies in
            guard let self = self else { return }
            self.trendingMovies = movies
            self.isFetchingTrending = false
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                self.collectionView.reloadData()
            }
        }
        
        movieVM.searchResultsUpdated = { [weak self] movies in
            guard let self = self else { return }
            self.searchResults = movies
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
        
        movieVM.errorMessageUpdated = { [weak self] errorMessage in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.showErrorAlert(message: errorMessage)
                self.activityIndicator.stopAnimating()
                
            }
        }
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func loadMovies() {
        print("Loading Now Playing Movies for page: \(currentPageNowPlaying)")
        print("Loading Trending Movies for page: \(currentPageTrending)")
        
        if !isFetchingNowPlaying {
            isFetchingNowPlaying = true
            movieVM.fetchNowPlayingMovies(page: currentPageNowPlaying)
        }
        if !isFetchingTrending{
            isFetchingTrending = true
            movieVM.fetchTrendingMovies(page: currentPageTrending)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentOffset = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let scrollViewHeight = scrollView.frame.size.height
        let scrollViewWidth = scrollView.frame.size.width
        
        if contentOffset > contentHeight - scrollViewHeight - 100 {
            if !isFetchingNowPlaying && currentPageNowPlaying < 3 {
                currentPageNowPlaying += 1
                DispatchQueue.main.async {
                    self.activityIndicator.startAnimating()
                }
                loadMovies()
            }
            if !isFetchingTrending && currentPageTrending < 3 {
                currentPageTrending += 1
                DispatchQueue.main.async {
                    self.activityIndicator.startAnimating()
                }
                loadMovies()
            }
        }
    }
    
    private func createLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { [weak self] sectionIndex, _ in
            guard let section = Section(rawValue: sectionIndex) else { return nil }
            
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                    heightDimension: .absolute(44))
            let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top)
            
            sectionHeader.pinToVisibleBounds = false
            sectionHeader.zIndex = 2
            
            switch section {
            case .trending, .searchResults:
                // Horizontal scroll section
                let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(200),
                                                      heightDimension: .absolute(300))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .estimated(200),
                                                       heightDimension: .absolute(300))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                let sectionLayout = NSCollectionLayoutSection(group: group)
                sectionLayout.orthogonalScrollingBehavior = .continuous
                sectionLayout.interGroupSpacing = 10
                sectionLayout.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20)
                sectionLayout.boundarySupplementaryItems = [sectionHeader]
                
                return sectionLayout
                
            case .nowPlaying:
                // Grid (vertical) section
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5),
                                                      heightDimension: .absolute(300))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 5, bottom: 10, trailing: 5)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                       heightDimension: .absolute(300))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item, item])
                
                let sectionLayout = NSCollectionLayoutSection(group: group)
                sectionLayout.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20)
                sectionLayout.boundarySupplementaryItems = [sectionHeader]
                
                return sectionLayout
            }
        }
    }
    
}

extension HomeViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return searchController.isActive ? 1 : Section.allCases.count - 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let section = Section(rawValue: section) else {
            return 0
        }
        
        if searchController.isActive {
            return searchResults.count
        } else {
            switch section {
            case .nowPlaying:
                return nowPlayingMovies.count
            case .trending:
                return trendingMovies.count
            case .searchResults:
                return searchResults.count
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let section = Section(rawValue: indexPath.section) else {
            fatalError("Invalid section")
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieCollectionViewCell.identifier, for: indexPath) as! MovieCollectionViewCell
        
        if searchController.isActive{
            if !searchResults.isEmpty {
                let movie = searchResults[indexPath.item]
                cell.configure(movie: movie, viewModel: movieVM)
            }
        } else{
            switch section {
            case .trending:
                let movie = trendingMovies[indexPath.item]
                cell.configure(movie: movie, viewModel: movieVM)
            case .nowPlaying:
                let movie = nowPlayingMovies[indexPath.item]
                cell.configure(movie: movie, viewModel: movieVM)
            case .searchResults:
                let movie = searchResults[indexPath.item]
                cell.configure(movie: movie, viewModel: movieVM)
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TitleHeaderView.identifier, for: indexPath) as! TitleHeaderView
            
            if searchController.isActive {
                headerView.titleLabel.text = ""
            }
            else{
                // Get the section title from the enum
                if let section = Section(rawValue: indexPath.section) {
                    headerView.titleLabel.text = section.title
                    headerView.titleLabel.textColor = .white
                } else {
                    headerView.titleLabel.text = ""
                }
            }
            
            return headerView
        }
        return UICollectionReusableView()
    }
}

extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let section = Section(rawValue: indexPath.section) else{
            return
        }
        
        var selectedMovie: Movie?
        
        if searchController.isActive {
            selectedMovie = searchResults[indexPath.item]
        } else {
            switch section {
            case .trending:
                selectedMovie = trendingMovies[indexPath.item]
            case .nowPlaying:
                selectedMovie = nowPlayingMovies[indexPath.item]
            case .searchResults:
                selectedMovie = searchResults[indexPath.item]
            }
        }
        
        if let movie = selectedMovie{
            print("Selected Movie: \(movie.title ?? "")")
            let detailedVC = DetailedMovieViewController(viewModel: movieVM)
            detailedVC.movie = movie
            self.navigationController?.pushViewController(detailedVC, animated: true)
        }
    }
}

extension HomeViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            movieVM.updateSearchQuery(with: searchText)
        }
    }
}
