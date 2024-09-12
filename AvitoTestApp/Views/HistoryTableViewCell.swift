//
//  HistoryTableViewCell.swift
//  AvitoTestApp
//
//  Created by Нурбол Мухаметжан on 12.09.2024.
//

import UIKit

class HistoryTableViewCell: UITableViewCell {

    static let identifier = "HistoryTableViewCell"
    
    let queryLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: HistoryTableViewCell.identifier)
    }

    required init?(coder: NSCoder) {
        fatalError("Error coder not inited yet")
    }
    
    
    
}
