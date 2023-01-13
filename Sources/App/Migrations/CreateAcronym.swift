import Fluent

struct CreateAcronym: AsyncMigration {
    
    func prepare(on database: FluentKit.Database) async throws {
        
        try await database.schema("acronyms")
            .id()
            .field("short", .string, .required)
            .field("long", .string, .required)
            .field("userID", .uuid, .required, .references("users", "id"))
            .create()
        
    }
    
    func revert(on database: FluentKit.Database) async throws {
        
        try await database.schema("acronyms")
            .delete()
        
    }
    
}
