//
//  Poll.swift
//  App
//
//  Created by Peter Bødskov on 28/07/2019.
//

import Foundation
import Vapor

struct Poll {
    var id: UUID?
    var title: String
    var option1: String
    var option2: String
    var votes1: Int
    var votes2: Int
}

extension Poll: Content { }
