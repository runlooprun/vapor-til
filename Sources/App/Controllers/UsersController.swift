import Vapor

struct UsersController: RouteCollection {
	
	func boot(router: Router) throws {
		let usersRoute = router.grouped("api", "users")
		usersRoute.post(User.self, use: self.createHandler)
		usersRoute.get(use: self.getAllHandler)
		usersRoute.get(User.parameter, use: self.getHandler)
		usersRoute.get(User.parameter, "acronyms", use: self.getAcronymsHandler)
	}
	
	/// Create a user
	func createHandler(_ req: Request, user: User) throws -> Future<User> {
		return user.save(on: req)
	}
	
	/// Get all users
	func getAllHandler(_ req: Request) throws -> Future<[User]> {
		return User.query(on: req).all()
	}
	
	/// Get the user specified by ID
	func getHandler(_ req: Request) throws -> Future<User> {
		return try req.parameters.next(User.self)
	}
	
	/// Get acronyms
	func getAcronymsHandler(_ req: Request) throws -> Future<[Acronym]> {
		return try req.parameters.next(User.self)
			.flatMap(to: [Acronym].self) { user in
				return try user.acronyms.query(on: req).all()
			}
	}
}
