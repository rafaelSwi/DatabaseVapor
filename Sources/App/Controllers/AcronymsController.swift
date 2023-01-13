import Vapor
import Fluent

struct AcronymsController: RouteCollection {
    
    func boot(routes: Vapor.RoutesBuilder) throws {
        
        let acronymsRoutes = routes.grouped("api","acronyms")
        
        acronymsRoutes.get(use: getAllHandler)
        acronymsRoutes.post(use: createHandler)
        acronymsRoutes.get(":acronymID", use: getHandler)
        acronymsRoutes.put(":acronymID", use: updateHandler)
        acronymsRoutes.delete(":acronymID", use: deleteHandler)
        acronymsRoutes.get("search", use: searchHandler)
        acronymsRoutes.get("first", use: getFirstHandler)
        acronymsRoutes.get("sorted", use: sortedHandler)
        acronymsRoutes.get(":acronymID", "user", use: getUserHandler)
        acronymsRoutes.post(
            ":acronymID",
            "categories",
            ":categoryID",
            use: addCategoryHandler
        )
        
    }
    
    // GET ALL ACRONYMS IN THE DATABASE
    func getAllHandler (_ req: Request) async throws -> [Acronym] {
        
        try await Acronym.query(on: req.db).all()
        
    }
    
    // POST (or create) A NEW ACRONYM IN THE DATABASE
    func createHandler (_ req: Request) async throws -> Acronym {
        
        let data = try req.content.decode(CreateAcronymData.self)
        
        let acronym = Acronym(
            id: UUID(),
            short: data.short,
            long: data.long,
            userID: data.userID
        )
        
        try await acronym.save(on: req.db)
        return acronym
        
    }
    
    // GET A SINGLE ACRONYM BY ID (and handle the error if the acronym id is invalid)
    func getHandler (_ req: Request) async throws -> Acronym {
        
        guard let acronym = try! await Acronym.find(
            req.parameters.get("acronymID"),
            on: req.db
        ) else {
            throw Abort(.notFound)
        }
        
        return acronym
        
    }
    
    // UPDATE THE ACRONYM BY USING ID
    func updateHandler (_ req: Request) async throws -> Acronym {
        
        let updatedAcronym = try req.content.decode(CreateAcronymData.self)
        
        guard let acronym = try! await Acronym.find(
            req.parameters.get("acronymID"),
            on: req.db
        ) else {
            throw Abort(.notFound)
        }
        
        acronym.short = updatedAcronym.short
        acronym.long = updatedAcronym.long
        acronym.$user.id = updatedAcronym.userID
        
        try await acronym.update(on: req.db)
        return acronym
        
    }
    
    // DELETE ACRONYM BY USING ID AND RETURN A HTTPSTATUS
    func deleteHandler (_ req: Request) async throws -> HTTPStatus {
        
        guard let acronym = try! await Acronym.find(
            req.parameters.get("acronymID"),
            on: req.db
        ) else {
            throw Abort(.notFound)
        }
        
        try await acronym.delete(on: req.db)
        return HTTPStatus.ok
        
    }
    
    // SEARCH FOR ACRONYMS BY USING A "TERM"
    func searchHandler (_ req: Request) async throws -> [Acronym] {
        
        guard let searchTerm = req.query[String.self, at: "term"] else {
            throw Abort(.badRequest)
        }
        
        return try await Acronym.query(on: req.db)
            .filter(\.$short == searchTerm)
            .all()
        
    }
    
    // GET THE FIRST ACRONYM
    func getFirstHandler (_ req: Request) async throws -> Acronym {
        
        guard let firstAcronym = try await Acronym.query(on: req.db).first() else {
            throw Abort(.notFound)
        }
        
        return firstAcronym
        
    }
    
    // GET ACRONYMS SORTED
    func sortedHandler (_ req: Request) async throws -> [Acronym] {
        
        try await Acronym.query(on: req.db)
            .sort(\.$short, .ascending)
            .all()
        
    }
    
    // GET THE USER WHO "OWNS" THE ACRONYM
    func getUserHandler (_ req: Request) async throws -> User {
        
        guard let acronym = try await Acronym.find(
            req.parameters.get("acronymID"),
            on: req.db
        ) else {
            throw Abort(.notFound)
        }
        
        guard let user = try await User.find(
            acronym.$user.id,
            on: req.db
        ) else {
            throw Abort(.notFound)
        }
        
        return user
        
    }
    
    func addCategoryHandler (_ req: Request) -> EventLoopFuture<HTTPStatus> {
        
        let acronymQuery = Acronym.find(
            req.parameters.get("acronymID"),
            on: req.db
        ).unwrap(or: Abort(.notFound))
        
        let categoryQuery = Category.find(
            req.parameters.get("categoryID"),
            on: req.db
        ).unwrap(or: Abort(.notFound))
        
        return acronymQuery.and(categoryQuery)
            .flatMap { acronym, category in
                acronym
                    .$categories
                    .attach(category, on: req.db)
                    .transform(to: .created)
            }
    }
    
}

struct CreateAcronymData: Content {
    
    let short: String
    let long: String
    let userID: UUID
    
}
