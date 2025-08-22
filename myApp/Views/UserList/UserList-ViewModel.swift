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
		
		func loadData() async {
			do {
				try await fetchUsers()
			} catch FetchUserError.invalidUrl {
				showAlert = true
				isLoading = .failed
				print("ERROR: invalid url")
			} catch FetchUserError.invalidResponse {
				showAlert = true
				isLoading = .failed
				print("ERROR: invalid response")
			} catch FetchUserError.notFound {
				showAlert = true
				isLoading = .failed
				print("ERROR: users not found")
			} catch FetchUserError.invalidData {
				showAlert = true
				isLoading = .failed
				print("ERROR: invalid data")
			} catch {
				showAlert = true
				isLoading = .failed
				print("Error loading users data: \(error.localizedDescription)")
			}
		}
	}
}
