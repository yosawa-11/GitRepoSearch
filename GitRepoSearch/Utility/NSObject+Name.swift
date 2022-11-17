//
//  NSObject+Name.swift
//  GitRepoSearch
//
//  Created by eleven on 2022/11/17.
//

import Foundation

extension NSObject {
    static var name: String {
        String(describing: Self.self)
    }
}
