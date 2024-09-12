//
//  ImageCollectionViewCell.swift
//  AvitoTestApp
//
//  Created by Нурбол Мухаметжан on 12.09.2024.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "ImageCollectionViewCell"
    
    enum CellState {
        case loading
        case error(String)
        case content
    }
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let authorNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Arial", size: 16)
        return label
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    private let errorLabel: UILabel = {
        let label = UILabel()
        label.textColor = .red
        label.font = UIFont(name: "Arial", size: 14)
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init hasn't been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(imageView)
        contentView.addSubview(authorNameLabel)
        contentView.addSubview(activityIndicator)
        contentView.addSubview(errorLabel)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        authorNameLabel.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 160),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            authorNameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 15),
            authorNameLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
            
            errorLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            errorLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            errorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            errorLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10)
        ])
    }
    
    func configure(with image: Image, state: CellState) {
        DispatchQueue.main.async {
            switch state {
            case .loading:
                self.activityIndicator.startAnimating()
                self.imageView.image = UIImage(systemName: "photo") // Placeholder image
                self.authorNameLabel.text = "Loading..."
                self.errorLabel.isHidden = true
                
            case .error(let message):
                self.activityIndicator.stopAnimating()
                self.imageView.image = UIImage(systemName: "exclamationmark.triangle")
                self.authorNameLabel.text = "Error"
                self.errorLabel.text = message
                self.errorLabel.isHidden = false
                
            case .content:
                self.activityIndicator.stopAnimating()
                self.errorLabel.isHidden = true
                self.authorNameLabel.text = image.user.name
                
                guard let url = URL(string: image.urls.regular) else {
                    self.configure(with: image, state: .error("Invalid image URL."))
                    return
                }
                
                self.imageView.image = UIImage(systemName: "photo")
                self.activityIndicator.startAnimating()
                
                URLSession.shared.dataTask(with: url) { data, response, error in
                    if let error = error {
                        DispatchQueue.main.async {
                            self.configure(with: image, state: .error("Failed to load image: \(error.localizedDescription)"))
                        }
                        return
                    }
                    
                    guard let data = data, let downloadedImage = UIImage(data: data) else {
                        DispatchQueue.main.async {
                            self.configure(with: image, state: .error("Failed to load image."))
                        }
                        return
                    }
                    
                    DispatchQueue.main.async {
                        self.imageView.image = downloadedImage
                        self.activityIndicator.stopAnimating()
                    }
                }.resume()
            }
        }
    }
}
