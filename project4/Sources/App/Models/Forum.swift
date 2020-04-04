//
//  Forum.swift
//  App
//
//  Created by Peter Bødskov on 20/03/2020.
//

import Foundation
import Vapor
import FluentSQLite

struct Forum {
    var id: Int?
    let name: String
}

extension Forum: Content { }
extension Forum: SQLiteModel { }
extension Forum: Migration { }
