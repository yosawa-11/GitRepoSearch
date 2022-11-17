//
//  UITableView+DequeueCell.swift
//  GitRepoSearch
//
//  Created by eleven on 2022/11/17.
//

import UIKit

extension UITableView {
    func dequeueReusableCell<T: UITableViewCell>(cellClass: T.Type, for indexPath: IndexPath) -> T {
        dequeueReusableCell(withIdentifier: T.name, for: indexPath) as? T ?? { fatalError("deque失敗") }()
    }
}
