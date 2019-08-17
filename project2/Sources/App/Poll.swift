//
//  Poll.swift
//  App
//
//  Created by Peter Bødskov on 28/07/2019.
//

import Foundation
import Vapor
import Fluent
import FluentSQLite

struct Poll {
    var id: UUID?
    var title: String
    var option1: String
    var option2: String
    var votes1: Int
    var votes2: Int
}

extension Poll: Content { }

extension Poll: SQLiteUUIDModel { }

extension Poll: Migration { }

extension Poll: Parameter {
    
}
