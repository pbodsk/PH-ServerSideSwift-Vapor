import Routing
import Vapor

/// Register your application's routes here.
///
/// [Learn More →](https://docs.vapor.codes/3.0/getting-started/structure/#routesswift)
public func routes(_ router: Router) throws {
    router.get("hello") { req in
        return "Hello, world!"
    }
    
    router.get("order", String.parameter, Int.parameter) { req -> String in
        //Order matters
        let string = try req.parameters.next(String.self)
        let integer = try req.parameters.next(Int.self)
        return "I got this string: \(string) and this int: \(integer)"
    }
        
    router.get("articles", Article.parameter) { req -> Future<Article> in
        let article = try req.parameters.next(Article.self)
        return article.map(to: Article.self) { article in
            guard let article = article else {
                throw Abort(.badRequest)
            }
            return article
        }
    }
    
    router.group("hello") { group in
        group.get("world") { req in
            return "Hello World"
        }
        
        group.get("kitty") { group in
            return "Hello Kitty"
        }
    }
    
//    router.group("article", Int.parameter) { group in
//        group.get("read") { req -> String in
//            let num = try req.parameters.next(Int.self)
//            return "Reading article number \(num)"
//        }
//        
//        group.get("edit") { req -> String in
//            let num = try req.parameters.next(Int.self)
//            return "Editing article number \(num)"
//        }
//    }
    
    let article = router.grouped("article", Int.parameter)
    article.get("read") { req -> String in
        let num = try req.parameters.next(Int.self)
        return "Reading article number \(num)"
    }

    article.get("edit") { req -> String in
        let num = try req.parameters.next(Int.self)
        return "Editing article number \(num)"
    }
    
    //Add a collection
    try router.grouped("admin").register(collection: AdminCollection())
}

final class AdminCollection: RouteCollection {
    func boot(router: Router) throws {
        let article = router.grouped("article", Int.parameter)
        article.get("read") { req -> String in
            let num = try req.parameters.next(Int.self)
            return "* Reading article number \(num)"
        }
        
        article.get("edit") { req -> String in
            let num = try req.parameters.next(Int.self)
            return "* Editing article number \(num)"
        }

    }
    
    
}
