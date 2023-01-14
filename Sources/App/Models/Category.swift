import Fluent
import Vapor

final class Category: Model, Content {
    
    static let schema = "categories"
    
    @ID
    var id: UUID?
    
    @Field (key: "name")
    var name: String
    
    @Siblings (
        through: AcronymCategoryPivot.self,
        from: \.$category,
        to: \.$acronym
    )
    var acronyms: [Acronym]
    
    init () {}
    
    init (
        id: UUID?,
        name: String
    ) {
        self.id = UUID()
        self.name = name
    }
    
}
