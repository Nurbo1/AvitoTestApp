//
//  Image.swift
//  AvitoTestApp
//
//  Created by Нурбол Мухаметжан on 11.09.2024.
//

import Foundation

struct Images: Codable {
    let results: [Image]
}

struct Image: Codable {
    let description: String?
    let alt_description: String?
    let urls: Urls
    let user: User
}

struct Urls: Codable {
    let regular: String
}

struct User: Codable {
    let name: String
}
