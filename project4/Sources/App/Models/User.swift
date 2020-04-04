//
//  User.swift
//  App
//
//  Created by Peter Bødskov on 04/04/2020.
//

import Foundation
import Vapor
import Fluent
import FluentSQLite

struct User {
    var id: Int?
    var username: String
    var password: String
}

extension User: Content { }
extension User: SQLiteModel { }
extension User: Migration { }
