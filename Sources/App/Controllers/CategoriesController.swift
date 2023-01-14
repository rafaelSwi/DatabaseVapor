import Fluent
import Vapor

struct CategoriesController: RouteCollection {
    
    
    func boot(routes: Vapor.RoutesBuilder) throws {
        
        let categoriesRoute = routes.grouped("api", "categories")
        
        categoriesRoute.post(use: createHandler)
        categoriesRoute.get(use: getAllHandler)
        categoriesRoute.get(":categoryID", use: getHandler)
        categoriesRoute.get(":categoryID", "acronyms", use: getAcronymHandler)
        
    }
    
    func createHandler (_ req: Request) async throws -> Category {
        
        let category = try req.content.decode(Category.self)
        
        try await category.save(on: req.db)
        
        return category
        
    }
    
    func getAllHandler (_ req: Request) async throws -> [Category] {
        
        let categories = try await Category.query(on: req.db).all()
        
        return categories
        
    }
    
    func getHandler (_ req: Request) async throws -> Category {
        
        guard let category = try await Category.find(
            req.parameters.get("categoryID"),
            on: req.db
        ) else {
            throw Abort (.notFound)
        }
        
        return category
        
    }
    
    func getAcronymHandler (_ req: Request) async throws -> [Acronym] {
        
        guard let category = try await Category.find(
            req.parameters.get("categoryID"),
            on: req.db
        ) else {
            throw Abort(.notFound)
        }
        
        let acronyms = try await category.$acronyms.query(on: req.db).all()
        
        return acronyms
                
    }

}
