import Routing
import Vapor
import Foundation

/// Register your application's routes here.
///
/// [Learn More →](https://docs.vapor.codes/3.0/getting-started/structure/#routesswift)
public func routes(_ router: Router) throws {
    router.post("polls", "vote", Poll.parameter, Int.parameter) { req -> Future<Poll> in
        let poll = try req.parameters.next(Poll.self)
        let vote = try req.parameters.next(Int.self)
        
        return poll.flatMap(to: Poll.self) { poll in
            var mutablePoll = poll
            if vote == 1 {
                mutablePoll.votes1 += 1
            } else if vote == 2 {
                mutablePoll.votes2 += 1
            }
            return mutablePoll.save(on: req)
        }
    }
    
    router.get("polls", Poll.parameter) { req -> Future<Poll> in
        return try req.parameters.next(Poll.self)
    }
    
    router.delete("polls", Poll.parameter) { req -> Future<HTTPStatus> in
        let poll = try req.parameters.next(Poll.self)
        return poll.delete(on: req).map(to: HTTPStatus.self) { deletedPoll -> HTTPStatus in
            return .ok
        }
    }

    router.post(Poll.self, at: "polls", "create") { req, poll -> Future<Poll> in
        return poll.save(on: req)
    }
    
    router.get("polls", "list") { req -> Future<[Poll]> in
        return Poll.query(on: req).all()
    }
}
