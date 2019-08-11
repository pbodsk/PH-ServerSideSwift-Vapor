import Routing
import Vapor
import Foundation

/// Register your application's routes here.
///
/// [Learn More →](https://docs.vapor.codes/3.0/getting-started/structure/#routesswift)
public func routes(_ router: Router) throws {
    router.post("polls", "vote", UUID.parameter, Int.parameter) { req -> Future<Poll> in
        let id = try req.parameters.next(UUID.self)
        let vote = try req.parameters.next(Int.self)
        
        return Poll.find(id, on: req).flatMap(to: Poll.self) { poll in
            guard var poll = poll else {
                throw Abort(.notFound)
            }
            
            if vote == 1 {
                poll.votes1 += 1
            } else if vote == 2 {
                poll.votes2 += 1
            }
            
            return poll.save(on: req)
        }
    }
    
    router.get("polls", UUID.parameter) { req -> Future<Poll> in
        let id = try req.parameters.next(UUID.self)
        
        return Poll.find(id, on: req).flatMap(to: Poll.self) { poll in
            guard let poll = poll else {
                throw Abort(.notFound)
            }
            
            return Future.map(on: req) { return poll }
        }
    }
    
    router.delete("polls", UUID.parameter) { req -> Future<HTTPStatus> in
        let id = try req.parameters.next(UUID.self)
        
        return Poll.find(id, on: req).flatMap { poll in
            guard let poll = poll else {
                throw Abort(.notFound)
            }
            
            return poll.delete(on: req).map {
                return .ok
            }
        }
    }

    
    router.post(Poll.self, at: "polls", "create") { req, poll -> Future<Poll> in
        return poll.save(on: req)
    }
    
    router.get("polls", "list") { req -> Future<[Poll]> in
        return Poll.query(on: req).all()
    }
}
