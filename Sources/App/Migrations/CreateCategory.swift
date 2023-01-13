import Fluent

struct CreateCategory: AsyncMigration {
    
    func prepare(on database: FluentKit.Database) async throws {
        
        try await database.schema("categories")
            .id()
            .field("name", .string, .required)
            .create()
        
    }
    
    func revert(on database: FluentKit.Database) async throws {
        
        try await database.schema("categories")
            .delete()
        
    }
    
}
