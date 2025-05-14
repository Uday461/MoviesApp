//
//  BookMarkedViewController.swift
//  Movies App (Inshorts)
//
//  Created by Banavath UdayKiran Naik on 10/05/25.
//

import UIKit

class BookMarkedViewController: UIViewController {
    private var tableView = UITableView()
    private var bookMarkedMovies: [Movie] = []
    private let movieVM: MoviesViewModelProtocol
    
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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupBookMarkedTableView()
        loadBookmarkedMovies()
    }
    
    func setupBookMarkedTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(BookMarkedTableViewCell.self, forCellReuseIdentifier: BookMarkedTableViewCell.identifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .black
        view.addSubview(tableView)
        
        // Set up constraints for the table view
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        tableView.rowHeight = 160
        
    }
    
    private func loadBookmarkedMovies() {
        bookMarkedMovies = movieVM.fetchBookMarkedMovies()
        print("BookMarked Movies: \(bookMarkedMovies.count)...!!!")
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}


extension BookMarkedViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bookMarkedMovies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: BookMarkedTableViewCell.identifier, for: indexPath) as? BookMarkedTableViewCell else {
            fatalError("Could not dequeue a BookMarkedTableViewCell")
        }
        
        let movie = bookMarkedMovies[indexPath.row]
        cell.configure(movie: movie, viewModel: movieVM)
        cell.selectionStyle = .none
        return cell
    }
}


extension BookMarkedViewController: UITableViewDelegate {
    
}
