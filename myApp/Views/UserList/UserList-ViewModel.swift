import Foundation

let BASE_URL = "https://www.hackingwithswift.com/samples/friendface.json"
let SORT_OPTIONS = ["Name", "Date"]
let FILTER_OPTIONS = ["All", "Active", "Inactive"]

enum FetchUserError: Error {
	case notFound, invalidUrl, invalidResponse, invalidData
}

enum LoadingState {
	case loading, success, failed
}

///MARK: Example case for using MVVM architecture
extension UserListView {
	@Observable
	final class ViewModel {
		var users: [User]
		var showAlert: Bool
		var isLoading: LoadingState
		
		init(users: [User] = [], showAlert: Bool = false, isLoading: LoadingState = .loading) {
			self.users = users
			self.showAlert = showAlert
			self.isLoading = isLoading
		}
		
		func deleteItems(at offsets: IndexSet) {
			users.remove(atOffsets: offsets)
		}
		
		func fetchUsers() async throws {
			if !users.isEmpty {
				isLoading = .success
				return
			}
			
			guard let url = URL(string: BASE_URL) else {
				throw FetchUserError.invalidUrl
			}
			
			///MARK: Example of HTTP POST request
			//		guard let encoded = try? JSONEncoder().encode(payload) else {
			//			print("Failed to encode")
			//			return
			//		}
			//		var request = URLRequest(url: url)
			//		request.setValue("application/json", forHTTPHeaderField: "Content-Type")
			//		request.httpMethod = "POST"
			// 		let (data, response) = try await URLSession.shared.upload(for: request, from: encoded)
			
			do {
				let (data, response) = try await URLSession.shared.data(from: url)
				guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
					throw FetchUserError.invalidResponse
				}
				
				let decoder = JSONDecoder()
				// decoder.keyDecodingStrategy = .convertFromSnakeCase // if needed
				let usersData = try decoder.decode([User].self, from: data)
				
				if usersData.isEmpty {
					throw FetchUserError.notFound
				}
				
				for user in usersData {
					users.append(user)
				}
				isLoading = .success
			} catch {
				throw FetchUserError.invalidData
			}
		}
		
		func handleUserError(_ error: FetchUserError) {
			switch error {
			case .invalidUrl:
				showAlert = true
				isLoading = .failed
				print("ERROR: invalid url")
			case .invalidResponse:
				showAlert = true
				isLoading = .failed
				print("ERROR: invalid response")
			case .notFound:
				showAlert = true
				isLoading = .failed
				print("ERROR: users not found")
			case .invalidData:
				showAlert = true
				isLoading = .failed
				print("ERROR: invalid data")
			}
		}
		
		func loadData() async {
			do {
				try await fetchUsers()
			} catch FetchUserError.invalidUrl {
				handleUserError(FetchUserError.invalidUrl)
			} catch FetchUserError.invalidResponse {
				handleUserError(FetchUserError.invalidResponse)
			} catch FetchUserError.notFound {
				handleUserError(FetchUserError.notFound)
			} catch FetchUserError.invalidData {
				handleUserError(FetchUserError.invalidData)
			} catch {
				showAlert = true
				isLoading = .failed
				print("Error loading users data: \(error.localizedDescription)")
			}
		}
	}
}
