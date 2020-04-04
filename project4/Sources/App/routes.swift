import Routing
import Vapor
import Leaf
import Fluent
import FluentSQLite
import Crypto

/// Register your application's routes here.
///
/// [Learn More →](https://docs.vapor.codes/3.0/getting-started/structure/#routesswift)
public func routes(_ router: Router) throws {
    router.get("setup") { req -> String in
//        let forums = [
//            Forum(id: 1, name: "Taylor's Songs"),
//            Forum(id: 2, name: "Taylor's Albums"),
//            Forum(id: 3, name: "Taylor's Concerts")
//        ]
//
//        for forum in forums {
//            _ = forum.create(on: req)
//        }
        
        let messages = [
            Message(id: 1, forum: 1, title: "First Post", body: "And a body", parent: 0, user: "pebo", date: Date()),
            Message(id: 2, forum: 1, title: "Second Post", body: "And a body", parent: 0, user: "pebo", date: Date()),
            Message(id: 3, forum: 1, title: "First Reply", body: "And a body", parent: 1, user: "pebo", date: Date())
        ]
        
        for message in messages {
            _ = message.create(on: req)
        }
        
        return "OK"
    }
    
    router.get { req -> Future<View> in
        struct HomeContext: Codable {
            var username: String?
            var forums: [Forum]
        }
        
        
        return Forum
            .query(on: req)
            .all()
            .flatMap(to: View.self) { forums in
                let homeContext = HomeContext(username: getUsername(req), forums: forums)
                return try req.view().render("home", homeContext)
            }
        
    }
    
    router.get("forum", Int.parameter) { req -> Future<View> in
        struct ForumContext: Codable {
            var username: String?
            var forum: Forum
            var messages: [Message]
        }
        
        let forumID = try req.parameters.next(Int.self)
        return Forum
            .find(forumID, on: req)
            .unwrap(or: Abort(.notFound))
            .flatMap(to: View.self) { forum in
                let query = Message
                    .query(on: req)
                    .filter(\.forum == forumID)
                    .filter(\.parent == 0)
                    .all()
                
                return query.flatMap(to: View.self) { messages in
                    let context = ForumContext(username: getUsername(req),
                                               forum: forum,
                                               messages: messages)
                    
                    return try req.view().render("forum", context)
                }
            }
    }
    
    router.get("forum", Int.parameter, Int.parameter) { req -> Future<View> in
        struct MessageContext: Codable {
            var username: String?
            var forum: Forum
            var message: Message
            var replies: [Message]
        }
        
        //find forum, find message, find replies to message
        let forumID = try req.parameters.next(Int.self)
        let messageID = try req.parameters.next(Int.self)
        
        return Forum
            .find(forumID, on: req)
            .unwrap(or: Abort(.notFound))
            .flatMap(to: View.self) { forum in
                return Message
                    .find(messageID, on: req)
                    .unwrap(or: Abort(.notFound))
                    .flatMap(to: View.self) { message in
                        guard message.forum == forumID else { throw Abort(.notFound) }
                        
                        //Now find all messages attached to this message
                        let query = Message
                            .query(on: req)
                            .filter(\.parent == message.id!)
                            .all()
                        
                        return query.flatMap(to: View.self) { replies in
                            let context = MessageContext(username: getUsername(req),
                                                         forum: forum,
                                                         message: message,
                                                         replies: replies)
                            return try req.view().render("message", context)
                        }
                }
            }
    }
    
    // MARK: - User Management
    router.get("users", "create") { req -> Future<View> in
         return try req.view().render("users-create")
    }
    
    router.post("users", "create") { req -> Future<View> in
        var user = try req.content.syncDecode(User.self)
        
        //Does the user exist?
        return User.query(on: req)
            .filter(\.username == user.username)
            .first()
            .flatMap { existingUser in
                if existingUser == nil {
                    user.password = try BCrypt.hash(user.password)
                    return user.save(on: req).flatMap { _ in
                        return try req.view().render("users-welcome")
                    }
                } else {
                    let context = ["error", "true"]
                    return try req.view().render("users-create", context)
                }
        }
    }
    
    router.get("users", "login") { req -> Future<View> in
        return try req.view().render("users-login")
    }
    
    router.post(User.self, at: "users", "login") { req, user -> Future<View> in
        return User.query(on: req)
            .filter(\.username == user.username)
            .first()
            .flatMap { existingUser in
                if let existingUser = existingUser {
                    if try BCrypt.verify(user.password,
                                         created: existingUser.password) {
                        
                        let session = try req.session()
                        session["username"] = existingUser.username
                        
                        return try req.view().render("users-welcome")
                    }
                }
                let context = ["error", "true"]
                return try req.view().render("users-create", context)
            }
    }
    
    router.post("forum", Int.parameter, use: postOrReply)
    router.post("forum", Int.parameter, Int.parameter, use: postOrReply)
}

func getUsername(_ req: Request) -> String? {
    return try? req.session()["username"]
}

private func postOrReply(req: Request) throws -> Future<Response> {
    guard let username = getUsername(req) else {
        throw Abort(.unauthorized)
    }
    
    //find parameters
    let forumID = try req.parameters.next(Int.self)
    let parentID = (try? req.parameters.next(Int.self)) ?? 0
    let title: String = try req.content.syncGet(at: "title")
    let body: String = try req.content.syncGet(at: "body")
    
    let message = Message(id: nil,
                          forum: forumID,
                          title: title,
                          body: body,
                          parent: parentID,
                          user: username,
                          date: Date())
    
    return message
        .save(on: req)
        .map(to: Response.self) { message in
            if parentID == 0 {
                return req.redirect(to: "/forum/\(forumID)/\(message.id!)")
            } else {
                return req.redirect(to: "/forum/\(forumID)/\(parentID)")
            }
        }
    
}
