//
//  SearchViewController.swift
//  AvitoTestApp
//
//  Created by Нурбол Мухаметжан on 09.09.2024.
//

import UIKit

class SearchViewController: UIViewController {
    
    // MARK: - Properties
    
    var images: [Image] = []
    var filteredForOneImage: Bool = false
    var recentQueries: [String] = []
    
    // MARK: - UI Elements
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search for Images"
        searchBar.searchBarStyle = .minimal
        return searchBar
    }()
    
    private let filterButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "line.horizontal.3.decrease.circle"), for: .normal)
        button.tintColor = .gray
        return button
    }()
    
    private let historyTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "RecentQueryCell")
        tableView.isHidden = true
        return tableView
    }()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width / 2 - 20, height: 200)
        layout.minimumInteritemSpacing = 20
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: ImageCollectionViewCell.identifier)
        collectionView.isHidden = true
        return collectionView
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        setupUI()
        setupDelegates()
        loadRecentQueries()
    }
    
    // MARK: - Actions
    
    @objc private func filterButtonTapped() {
        filteredForOneImage.toggle()
        let newItemSize = filteredForOneImage
        ? CGSize(width: UIScreen.main.bounds.width - 40, height: 200)
        : CGSize(width: UIScreen.main.bounds.width / 2 - 20, height: 200)
        
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = newItemSize
        
        UIView.animate(withDuration: 0.3) {
            layout.invalidateLayout()
        }
    }
    
    private func updateRecentQueries(with query: String) {
        if recentQueries.contains(query) {
            recentQueries.removeAll { $0 == query }
        } else if recentQueries.count >= 5 {
            recentQueries.removeLast()
        }
        
        recentQueries.insert(query, at: 0)
        saveRecentQueries()
        historyTableView.reloadData()
    }
    
    private func saveRecentQueries() {
        UserDefaults.standard.set(recentQueries, forKey: "RecentQueries")
    }
    
    private func loadRecentQueries() {
        if let savedQueries = UserDefaults.standard.stringArray(forKey: "RecentQueries") {
            recentQueries = savedQueries
            historyTableView.reloadData()
        }
    }
    
    private func toggleHistoryTable() {
        historyTableView.isHidden = recentQueries.isEmpty
        collectionView.isHidden = !recentQueries.isEmpty
    }
    
    private func setupDelegates() {
        historyTableView.delegate = self
        historyTableView.dataSource = self
        searchBar.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
        filterButton.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(searchBar)
        view.addSubview(filterButton)
        view.addSubview(historyTableView)
        view.addSubview(collectionView)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        filterButton.translatesAutoresizingMaskIntoConstraints = false
        historyTableView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -34),
            
            filterButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            filterButton.leadingAnchor.constraint(equalTo: searchBar.trailingAnchor, constant: 5),
            filterButton.centerYAnchor.constraint(equalTo: searchBar.centerYAnchor),
            
            historyTableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            historyTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 5),
            historyTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -5),
            historyTableView.heightAnchor.constraint(equalToConstant: 500),
            
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 10),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 5),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -5),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func searchImages(with query: String) {
        updateRecentQueries(with: query)
        APICaller.shared.search(with: query) { [weak self] results in
            DispatchQueue.main.async {
                switch results {
                case .success(let images):
                    self?.images = images
                    self?.collectionView.reloadData()
                case .failure(let error):
                    print("DEBUG: Error with fetching [Image] \(error.localizedDescription)")
                }
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
}

// MARK: - UISearchBarDelegate

extension SearchViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        toggleHistoryTable()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        
        guard let query = searchBar.text?.trimmingCharacters(in: .whitespaces), !query.isEmpty, query.count >= 3 else {
            return
        }
        searchImages(with: query)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        historyTableView.isHidden = true
        collectionView.isHidden = false
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource

extension SearchViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCollectionViewCell.identifier, for: indexPath) as? ImageCollectionViewCell else {
            return UICollectionViewCell()
        }
        let image = images[indexPath.row]
        cell.configure(with: image, state: .content)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let image = images[indexPath.row]
        let vc = ImagePreviewViewController()
        vc.configure(with: image)
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recentQueries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecentQueryCell", for: indexPath)
        cell.textLabel?.text = recentQueries[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedQuery = recentQueries[indexPath.row]
        searchBar.text = selectedQuery
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}
