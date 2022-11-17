//
//  GitRepoSearchResultTableViewCell.swift
//  GitRepoSearch
//
//  Created by eleven on 2022/11/17.
//

import UIKit

final class GitRepoSearchResultTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    
    func apply(item: GitRepoItem) {
        titleLabel.text = item.name
        descLabel.text = item.description
    }
}
