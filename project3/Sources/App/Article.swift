//
//  Article.swift
//  App
//
//  Created by Peter Bødskov on 17/08/2019.
//

import Vapor

struct Article {
    var id: Int
    var title: String
    
    init(id: Int) {
        self.id = id
        self.title = "Custom parameters rock"
    }
}

extension Article: Parameter {

    static func resolveParameter(_ parameter: String, on container: Container) throws -> Future<Article?> {
        if let id = Int(parameter) {
            return Future.map(on: container) {
                return Article(id: id)
            }
        } else {
            throw Abort(.badRequest)
        }
    }    
}

extension Article: Content { }
