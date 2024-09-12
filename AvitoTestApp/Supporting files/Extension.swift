//
//  Extension.swift
//  AvitoTestApp
//
//  Created by Нурбол Мухаметжан on 12.09.2024.
//

import Foundation

extension String {
    func capitalizeFirstLetter() -> String {
        guard !self.isEmpty else {
            return self
        }
        
        let firstLetter = self.prefix(1).uppercased()
        let remainingLetters = self.dropFirst()
        
        return firstLetter + remainingLetters
    }
}

