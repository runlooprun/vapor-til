import Vapor
import Fluent

struct AcronymsController: RouteCollection {
	
	func boot(router: Router) throws {
		let acronymsRoutes = router.grouped("api", "acronyms")
		acronymsRoutes.get(use: self.getAllHandler)
		acronymsRoutes.post(Acronym.self, use: self.createHandler)
		acronymsRoutes.get(Acronym.parameter, use: self.getHandler)
		acronymsRoutes.put(Acronym.parameter, use: self.updateHandler)
		acronymsRoutes.delete(Acronym.parameter, use: self.deleteHandler)
		acronymsRoutes.get("search", use: self.searchHandler)
		acronymsRoutes.get("first", use: self.getFirstHandler)
		acronymsRoutes.get("sorted", use: self.sortedHandler)
	}
	
	/// Get all acronyms
	func getAllHandler(_ req: Request) throws -> Future<[Acronym]> {
		return Acronym.query(on: req).all()
	}
	
	/// Create (Post) a new acronym
	func createHandler(_ req: Request, acronym: Acronym) throws -> Future<Acronym> {
		return acronym.save(on: req)
	}
	
	/// Get an acronym specified by id
	func getHandler(_ req: Request) throws -> Future<Acronym> {
		return try req.parameters.next(Acronym.self)
	}
	
	/// Update (Put) an acronym specified by id
	func updateHandler(_ req: Request) throws -> Future<Acronym> {
		return try flatMap(to: Acronym.self, req.parameters.next(Acronym.self), req.content.decode(Acronym.self)) { acronym, updatedAcronym in
			acronym.short = updatedAcronym.short
			acronym.long = updatedAcronym.long
			return acronym.save(on: req)
		}
	}
	
	/// Delete an acronym specified by id
	func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
		return try req.parameters.next(Acronym.self)
			.delete(on: req) // “Fluent allows you to call delete(on:) directly on that Future. This helps tidy up code and reduce nesting. Fluent provides convenience functions for delete, update, create and save.”
			.transform(to: HTTPStatus.noContent)
	}
	
	/// Search acronym by term (short or long)
	func searchHandler(_ req: Request) throws -> Future<[Acronym]> {
		guard
			let searchTerm = req.query[String.self, at: "term"]
		else {
			throw Abort(.badRequest)
		}
		
		return Acronym.query(on: req).group(.or) { or in
			or.filter(\.short == searchTerm)
			or.filter(\.long == searchTerm)
		}.all()
	}
	
	/// Get first acronym
	func getFirstHandler(_ req: Request) throws -> Future<Acronym> {
		return Acronym.query(on: req)
			.first()
			.map(to: Acronym.self) { acronym in
				guard let acronym = acronym else {
					throw Abort(.notFound)
				}
				return acronym
			}
	}
	
	/// Get sorted acronyms
	func sortedHandler(_ req: Request) throws -> Future<[Acronym]> {
		return Acronym.query(on: req)
			.sort(\.short, .ascending)
			.all()
	}
}
