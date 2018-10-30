@testable import App
import Vapor
import XCTest
import FluentPostgreSQL


final class UserTests: XCTestCase {
	let usersName = "Alice"
	let usersUsername = "alicea"
	let usersURI = "/api/users/"
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
		let users = try app.getResponse(to: self.usersURI, decodeTo: [User].self)
		
		// Test
		XCTAssertEqual(users.count, 2)
		XCTAssertEqual(users[0].name, self.usersName)
		XCTAssertEqual(users[0].username, self.usersUsername)
		XCTAssertEqual(users[0].id, user.id)
	}
	
	func testUsersCanBeSavedWithAPI() throws {
		// Save user to DB
		let user = User(name: self.usersName, username: self.usersUsername)
		let receivedUser = try app.getResponse(to: self.usersURI, method: .POST, headers: ["Content-Type": "application/json"], data: user, decodeTo: User.self)
		
		// Test
		XCTAssertEqual(receivedUser.name, self.usersName)
		XCTAssertEqual(receivedUser.username, self.usersUsername)
		XCTAssertNotNil(receivedUser.id)
		
		// Get all users
		let users = try app.getResponse(to: self.usersURI, decodeTo: [User].self)
		
		// Test
		XCTAssertEqual(users.count, 1)
		XCTAssertEqual(users[0].name, self.usersName)
		XCTAssertEqual(users[0].username, self.usersUsername)
		XCTAssertEqual(users[0].id, receivedUser.id)
	}
	
	func testGettingASingleUserFromTheAPI() throws {
		// Save user to DB
		let user = try User.create(name: self.usersName, username: self.usersUsername, on: self.conn)
		
		// Get single user
		let receivedUser = try app.getResponse(to: "\(self.usersURI)\(user.id!)", decodeTo: User.self)
		
		// Test
		XCTAssertEqual(receivedUser.name, self.usersName)
		XCTAssertEqual(receivedUser.username, self.usersUsername)
		XCTAssertEqual(receivedUser.id, user.id)
	}
	
	func testGettingAUsersAcronymsFromTheAPI() throws {
		// Prepare
		let user = try User.create(on: conn)
		let acronymShort = "OMG"
		let acronymLong = "Oh My God"
		let acronym1 = try Acronym.create(short: acronymShort, long: acronymLong, user: user, on: self.conn)
		_ = try Acronym.create(short: "LOL", long: "Laugh Out Loud", user: user, on: self.conn)
		
		// Get acronyms
		let acronyms = try app.getResponse(to: "\(usersURI)\(user.id!)/acronyms", decodeTo: [Acronym].self)
		
		// Test
		XCTAssertEqual(acronyms.count, 2)
		XCTAssertEqual(acronyms[0].id, acronym1.id)
		XCTAssertEqual(acronyms[0].short, acronymShort)
		XCTAssertEqual(acronyms[0].long, acronymLong)
	}
	
	static let allTests = [
		("testUsersCanBeRetrievedFromAPI", testUsersCanBeRetrievedFromAPI),
		("testUsersCanBeSavedWithAPI", testUsersCanBeSavedWithAPI),
		("testGettingASingleUserFromTheAPI", testGettingASingleUserFromTheAPI),
		("testGettingAUsersAcronymsFromTheAPI", testGettingAUsersAcronymsFromTheAPI)
	]
}
