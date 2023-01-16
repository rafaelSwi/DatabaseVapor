import Fluent
import Vapor

func routes(_ app: Application) throws {
    
    app.get("hello") { req in
        return "Hello, world!"
    }
    
    // create a new variable for the type (struct) "AcronymsController" and try to register it
    let acronymsController = AcronymsController()
    try app.register(collection: acronymsController)
    
    let usersController = UsersController()
    try app.register(collection: usersController)
    
    let categoriesController = CategoriesController()
    try app.register(collection: categoriesController)
    
}


