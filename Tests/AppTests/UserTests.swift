import Foundation

@testable import App
import XCTVapor

final class UserTests: XCTestCase {
    
    let usersName = "Alice"
    let usersUsername = "alicea"
    let usersURI = "/api/users/"
    var app: Application!
    
    override func setUpWithError() throws {
        app = try Application.testable()
    }
    
    override func tearDownWithError() throws {
        app.shutdown()
    }
    
    func testUsersCanRetrieveFromAPI() throws {
        
        let user = try User.create(
            name: usersName,
            username: usersUsername,
            on: app.db
        )
        _ = try User.create(on: app.db)
        
        try app.test(.GET, usersURI, afterResponse: { response in
            
            XCTAssertEqual(response.status, .ok)
            
            let users = try response.content.decode([User].self)
            
            XCTAssertEqual(users.count, 2)
            XCTAssertEqual(users[0].name, usersName)
            XCTAssertEqual(users[0].username, usersUsername)
            XCTAssertEqual(users[0].id, user.id)
            
        })
    }
    
    func testUserCanBeSavedWithAPI () throws {
        
        let user = User(id: UUID(), name: usersName, username: usersUsername)
        
        try app.test(.POST, usersURI, beforeRequest: { request in
            
            try request.content.encode(user)
            
        }, afterResponse: { response in
            
            let receivedUser = try response.content.decode(User.self)
            
            XCTAssertEqual(receivedUser.name, usersName)
            XCTAssertEqual(receivedUser.username, usersUsername)
            XCTAssertNotNil(receivedUser.id)
            
            try app.test(.GET, usersURI, afterResponse: { secondResponse in
                
                let decodedResponse = try secondResponse.content.decode ( [User].self )
                
                XCTAssertEqual(decodedResponse.count, 1)
                XCTAssertEqual(decodedResponse[0].name, usersName)
                XCTAssertEqual(decodedResponse[0].username, usersUsername)
                XCTAssertNotNil(decodedResponse[0].id)
            })
        })
    }
    
    func testGettingASingleUserFromTheAPI () throws {
        
        let user = try User.create (
            name: usersName,
            username: usersUsername,
            on: app.db
        )
        
        try app.test(.GET, "\(usersURI)/\(user.id!)", afterResponse: { response in
            
            let receivedUser = try response.content.decode(User.self)
            
            XCTAssertEqual(receivedUser.name, usersName)
            XCTAssertEqual(receivedUser.username, usersUsername)
            XCTAssertEqual(receivedUser.id, user.id)
        })
    }
    
    func testGettingAUsersAcronymsFromTheAPI() throws {
        
        let user = try User.create(on: app.db)
        
        let acronymShort = "OMG"
        let acronymLong = "Oh My God"
        
        let acronym1 = try Acronym.create (
            short: acronymShort,
            long: acronymLong,
            user: user,
            on: app.db
        )
        
        _ = try Acronym.create (
            short: "LOL",
            long: "Laugh Out Loud",
            user: user,
            on: app.db
        )
        
        try app.test(.GET, "\(usersURI)\(user.id!)/acronyms", afterResponse: { response in
            
            let acronyms = try response.content.decode([Acronym].self)
            
            XCTAssertEqual(acronyms.count, 2)
            XCTAssertEqual(acronyms[0].id, acronym1.id)
            XCTAssertEqual(acronyms[0].short, acronym1.short)
            XCTAssertEqual(acronyms[0].long, acronym1.long)
        })
    }
    
}

// 160

