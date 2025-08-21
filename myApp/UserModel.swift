import Foundation
import SwiftData

let BASE_URL = "https://www.hackingwithswift.com/samples/friendface.json"
let SORT_OPTIONS = ["Name", "Date"]
let FILTER_OPTIONS = ["All", "Active", "Inactive"]

enum FetchUserError: Error {
	case notFound
}

@Model
final class Friend: Identifiable, Codable, Equatable {
	enum CodingKeys: String, CodingKey {
		case id, name
	}
	
	var id: String
	var name: String
	
	init(id: String, name: String) {
		self.id = id
		self.name = name
	}
	
	required init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.id = try container.decode(String.self, forKey: .id)
		self.name = try container.decode(String.self, forKey: .name)
	}
	
	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(self.id, forKey: .id)
		try container.encode(self.name, forKey: .name)
	}
	
	static func == (lhs: Friend, rhs: Friend) -> Bool {
		lhs.id == rhs.id
	}
}

@Model
final class User: Identifiable, Codable, Equatable {
	enum CodingKeys: String, CodingKey {
		case id, isActive, name, age, company, email, address, about, tags, friends, registered
	}
	
	var id: String
	var isActive: Bool
	var name: String
	var age: Int
	var company: String
	var email: String
	var address: String
	var about: String
	var tags: [String]
	var registered: Date
	@Relationship(deleteRule: .cascade) var friends: [Friend]
	
	init(id: String,
			 isActive: Bool,
			 name: String,
			 age: Int,
			 company: String,
			 email: String,
			 address: String,
			 about: String,
			 tags: [String],
			 friends: [Friend],
			 registered: Date) {
		self.id = id
		self.isActive = isActive
		self.name = name
		self.age = age
		self.company = company
		self.email = email
		self.address = address
		self.about = about
		self.tags = tags
		self.friends = friends
		self.registered = registered
	}
	
	required init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.id = try container.decode(String.self, forKey: .id)
		self.isActive = try container.decode(Bool.self, forKey: .isActive)
		self.name = try container.decode(String.self, forKey: .name)
		self.age = try container.decode(Int.self, forKey: .age)
		self.company = try container.decode(String.self, forKey: .company)
		self.email = try container.decode(String.self, forKey: .email)
		self.address = try container.decode(String.self, forKey: .address)
		self.about = try container.decode(String.self, forKey: .about)
		self.tags = try container.decode([String].self, forKey: .tags)
		self.friends = try container.decode([Friend].self, forKey: .friends)
		
		let registeredString = try container.decode(String.self, forKey: .registered)
		self.registered = ISO8601DateFormatter().date(from: registeredString) ?? Date()
	}
	
	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(self.id, forKey: .id)
		try container.encode(self.isActive, forKey: .isActive)
		try container.encode(self.name, forKey: .name)
		try container.encode(self.age, forKey: .age)
		try container.encode(self.company, forKey: .company)
		try container.encode(self.email, forKey: .email)
		try container.encode(self.address, forKey: .address)
		try container.encode(self.about, forKey: .about)
		try container.encode(self.tags, forKey: .tags)
		try container.encode(self.friends, forKey: .friends)
		try container.encode(self.registered, forKey: .registered)
	}
	
	static func == (lhs: User, rhs: User) -> Bool {
		lhs.id == rhs.id
	}
	
#if DEBUG
	static let example = User(
		id: "eccdf4b8-c9f6-4eeb-8832-28027eb70155",
		isActive: true,
		name: "Gale Dyer",
		age: 28,
		company: "Cemention",
		email: "galedyer@cemention.com",
		address: "652 Gatling Place, Kieler, Arizona, 1705",
		about: "Laboris ut dolore ullamco officia mollit reprehenderit qui eiusmod anim cillum qui ipsum esse reprehenderit. Deserunt quis consequat ut ex officia aliqua nostrud fugiat Lorem voluptate sunt consequat. Sint exercitation Lorem irure aliquip duis eiusmod enim. Excepteur non deserunt id eiusmod quis ipsum et consequat proident nulla cupidatat tempor aute. Aliquip amet in ut ad ullamco. Eiusmod anim anim officia magna qui exercitation incididunt eu eiusmod irure officia aute enim.",
		tags: ["irure", "labore", "et", "adipisicing", "veniam"],
		friends: [
			Friend(id: "1c18ccf0-2647-497b-b7b4-119f982e6292",
						 name: "Daisy Bond"),
			Friend(id: "a1ef63f3-0eab-49a8-a13a-e538f6d1c4f9",
						 name: "Tanya Roberson")
		],
		registered: ISO8601DateFormatter()
			.date(from: "2014-07-05T04:25:04-01:00") ?? Date()
	)
#endif
}
