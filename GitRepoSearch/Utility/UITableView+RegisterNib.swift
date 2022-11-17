//
//  UITableView+RegisterNib.swift
//  GitRepoSearch
//
//  Created by eleven on 2022/11/17.
//

import UIKit

extension UITableView {
    func register<T: UITableViewCell>(_ classType: T.Type) {
        let name = classType.name
        register(UINib(nibName: name, bundle: nil), forCellReuseIdentifier: name)
    }
}
