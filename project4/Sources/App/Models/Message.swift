//
//  Message.swift
//  App
//
//  Created by Peter Bødskov on 22/03/2020.
//

import Foundation
import Vapor
import Fluent
import FluentSQLite

struct Message {
    var id: Int?
    var forum: Int
    var title: String
    var body: String
    var parent: Int
    var user: String
    var date: Date
}

extension Message: Content {}
extension Message: SQLiteModel { }
extension Message: Migration { }

