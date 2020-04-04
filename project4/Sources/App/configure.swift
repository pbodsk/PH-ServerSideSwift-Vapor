import Vapor
import Fluent
import FluentSQLite
import Leaf

/// Called before your application initializes.
///
/// [Learn More →](https://docs.vapor.codes/3.0/getting-started/structure/#configureswift)
public func configure(
    _ config: inout Config,
    _ env: inout Environment,
    _ services: inout Services
) throws {
    // Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    // Configure the rest of your application here
    let directoryConfig = DirectoryConfig.detect()
    services.register(directoryConfig)
    
    try services.register(FluentSQLiteProvider())
    
    //Database
    var databaseConfig = DatabasesConfig()
    let db = try SQLiteDatabase(storage: .file(path: "\(directoryConfig.workDir)forums.db"))
    databaseConfig.add(database: db, as: .sqlite)
    services.register(databaseConfig)
    
    //Migrations
    var migrationConfig = MigrationConfig()
    migrationConfig.add(model: Forum.self, database: .sqlite)
    migrationConfig.add(model: Message.self, database: .sqlite)
    migrationConfig.add(model: User.self, database: .sqlite)
    services.register(migrationConfig)
    
    //Leaf
    try services.register(LeafProvider())
    config.prefer(LeafRenderer.self, for: ViewRenderer.self)
    
    // Session Middleware
    var middlewareConfig = MiddlewareConfig.default()
    middlewareConfig.use(SessionsMiddleware.self)
    services.register(middlewareConfig)
    config.prefer(MemoryKeyedCache.self, for: KeyedCache.self)
}
