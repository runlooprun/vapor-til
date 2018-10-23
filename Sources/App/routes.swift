import Vapor
import Fluent

/// Register your application's routes here.
public func routes(_ router: Router) throws {
	// Basic "It works" example
	router.get { req in
		return "It works!"
	}
	
	// Basic "Hello, world!" example
	router.get("hello") { req in
		return "Hello, world!"
	}
	
	/// Create (Post) a new acronym
	router.post("api", "acronyms") { req -> Future<Acronym> in
		return try req.content.decode(Acronym.self)
			.flatMap(to: Acronym.self) { acronym in
				return acronym.save(on: req)
			}
	}
	
	/// Get all acronyms
	router.get("api", "acronyms") { req -> Future<[Acronym]> in
		return Acronym.query(on: req).all()
	}
	
	/// Get an acronym specified by id
	router.get("api", "acronyms", Acronym.parameter) { req -> Future<Acronym> in
		return try req.parameters.next(Acronym.self)
	}
	
	/// Update (Put) an acronym specified by id
	router.put("api", "acronyms", Acronym.parameter) { req -> Future<Acronym> in
		return try flatMap(to: Acronym.self, req.parameters.next(Acronym.self), req.content.decode(Acronym.self)) { acronym, updatedAcronym in
			acronym.short = updatedAcronym.short
			acronym.long = updatedAcronym.long
			return acronym.save(on: req)
		}
	}
	
	/// Delete an acronym specified by id
	router.delete("api", "acronyms", Acronym.parameter) { req -> Future<HTTPStatus> in
		return try req.parameters.next(Acronym.self)
			.delete(on: req) // “Fluent allows you to call delete(on:) directly on that Future. This helps tidy up code and reduce nesting. Fluent provides convenience functions for delete, update, create and save.”
			.transform(to: HTTPStatus.noContent)
	}
	
//	/// Search acronym by term (short)
//	router.get("api", "acronyms", "search") { req -> Future<[Acronym]> in
//		guard
//			let searchTerm = req.query[String.self, at: "term"]
//		else {
//			throw Abort(.badRequest)
//		}
//		
//		return Acronym.query(on: req)
//			.filter(\.short == searchTerm)
//			.all()
//	}
	
	/// Search acronym by term (short or long)
	router.get("api", "acronyms", "search") { req -> Future<[Acronym]> in
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
	router.get("api", "acronyms", "first") { req -> Future<Acronym> in
		return Acronym.query(on: req)
			.first()
			.map(to: Acronym.self) { acronym in
				guard let acronym = acronym else {
					throw Abort(.notFound)
				}
				return acronym
			}
	}
}
