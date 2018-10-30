@testable import App
import Vapor
import XCTest
import FluentPostgreSQL


final class UserTests: XCTestCase {
	let usersName = "Alice"
	let usersUsername = "alicea"
	let usersURI = "/api/users"
	var app: Application!
	var conn: PostgreSQLConnection!
	
	override func setUp() {
		try! Application.reset()
		app = try! Application.testable()
		conn = try! app.newConnection(to: .psql).wait()
	}
	
	override func tearDown() {
		conn.close()
	}
	
	// MARK: Test
	
	func testUsersCanBeRetrievedFromAPI() throws {
		// Insert sample users
		let user = try User.create(name: self.usersName, username: self.usersUsername, on: self.conn)
		_ = try User.create(on: self.conn)
		
		// Get users
		let users = try app.getResponse(from: self.usersURI, decodeTo: [User].self)
		
		// Test
		XCTAssertEqual(users.count, 2)
		XCTAssertEqual(users[0].name, self.usersName)
		XCTAssertEqual(users[0].username, self.usersUsername)
		XCTAssertEqual(users[0].id, user.id)
	}
}
