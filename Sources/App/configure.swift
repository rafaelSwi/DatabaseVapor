import Fluent
import FluentPostgresDriver
import Vapor

// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    app.databases.use(.postgres(
        hostname: Environment.get("localhost") ?? "localhost",
        port: Environment.get("5432").flatMap(Int.init(_:)) ?? PostgresConfiguration.ianaPortNumber,
        username: Environment.get("postgres") ?? "postgres",
        password: Environment.get("rns2003") ?? "rns2003",
        database: Environment.get("estudolivro") ?? "estudolivro"
    ), as: .psql)
    
    app.migrations.add(CreateUser())
    app.migrations.add(CreateAcronym())
    app.migrations.add(CreateCategory())
    app.migrations.add(CreateAcronymCategoryPivot())
    
    app.logger.logLevel = .debug
    
    try app.autoMigrate().wait()

    // register routes
    try routes(app)
}
