import Vapor

struct CategoriesController: RouteCollection {
	func boot(router: Router) throws {
		let categoriesRoute = router.grouped("api", "categories")
		categoriesRoute.post(Category.self, use: self.createHandler)
		categoriesRoute.get(use: self.getAllHandler)
		categoriesRoute.get(Category.parameter, use: self.getHandler)
		categoriesRoute.get(Category.parameter, "acronyms", use: self.getAcronymsHandler)
	}
	
	/// Create category
	func createHandler(_ req: Request, category: Category) throws -> Future<Category> {
		return category.save(on: req)
	}
	
	/// Get all categories
	func getAllHandler(_ req: Request) throws -> Future<[Category]> {
		return Category.query(on: req).all()
	}
	
	/// Get the category specified by id
	func getHandler(_ req: Request) throws -> Future<Category> {
		return try req.parameters.next(Category.self)
	}
	
	/// Get all acronyms of specified category
	func getAcronymsHandler(_ req: Request) throws -> Future<[Acronym]> {
		return try req.parameters.next(Category.self)
			.flatMap(to: [Acronym].self) { category in
				return try category.acronyms.query(on: req).all()
			}
	}
}
