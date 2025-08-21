import Foundation

let BASE_URL = "https://www.hackingwithswift.com/samples/friendface.json"
let SORT_OPTIONS = ["Name", "Date"]
let FILTER_OPTIONS = ["All", "Active", "Inactive"]

enum FetchUserError: Error {
	case notFound
}

enum LoadingState {
	case loading, success, failed
}

// MARK: Example case for using MVVM architecture
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
			
			do {
				let url = URL(string: BASE_URL)!
				let (data, _) = try await URLSession.shared.data(from: url)
				let usersData = try JSONDecoder().decode([User].self, from: data)
				
				if usersData.isEmpty {
					throw FetchUserError.notFound
				}
				
				for user in usersData {
					users.append(user)
				}
				isLoading = .success
			} catch {
				showAlert = true
				isLoading = .failed
				print("Error fetching users: \(error.localizedDescription)")
			}
		}
		
		func loadData() async {
			do {
				try await fetchUsers()
			} catch {
				showAlert = true
				isLoading = .failed
				print("Error loading users data: \(error.localizedDescription)")
			}
		}
	}
}
