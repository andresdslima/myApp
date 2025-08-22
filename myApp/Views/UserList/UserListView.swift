import SwiftUI
import SwiftData

struct UserListView: View {
	@Environment(\.modelContext) var modelContext
	@Query var users: [User]
	@State private var viewModel = ViewModel()
	//	@State private var showAlert = false
	//	@State private var isLoading = LoadingState.loading
	
	var body: some View {
		ZStack {
			if !users.isEmpty {
				List {
					ForEach(users) { user in
						NavigationLink {
							UserDetailView(user: user)
						} label: {
							HStack {
								Label(
									title: { Text(user.name) },
									icon: { Image(systemName: "person.circle")
										.foregroundStyle(user.isActive ? .blue : .secondary) })
								
								Spacer()
								
								Text("\(user.isActive ? "Active" : "Inactive")")
									.foregroundStyle(user.isActive ? .green : .red)
							}
						}
						.padding(.vertical, 7)
					}
					.onDelete(perform: deleteItems)
				}
			} else if viewModel.isLoading != .loading {
				EmptyUsersView(loadData: loadData)
			}
		}
		.alert("Something went wrong", isPresented: $viewModel.showAlert) {} message: {
			Text("Please make sure you're connected to the internet or try again later.")
		}
		.task { await loadData() }
		.overlay {
			if viewModel.isLoading == .loading {
				ProgressView()
					.scaleEffect(3)
					.offset(y: -60)
			}
		}
	}
	
	init(
		filter: String,
		sortOrder: [SortDescriptor<User>]
	) {
		_users = Query(filter: #Predicate<User> { user in
			filter == FILTER_OPTIONS[1] ? user.isActive : filter == FILTER_OPTIONS[2] ? !user.isActive : true
		}, sort: sortOrder)
	}
	
	func deleteItems(at offsets: IndexSet) {
		for offset in offsets {
			modelContext.delete(users[offset])
		}
	}
	
	func fetchUsers() async throws {
		if !users.isEmpty {
			viewModel.isLoading = .success
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
				modelContext.insert(user)
			}
			viewModel.isLoading = .success
		} catch {
			throw FetchUserError.invalidData
		}
	}
	
	func loadData() async {
		do {
			try await fetchUsers()
		} catch FetchUserError.invalidUrl {
			viewModel.showAlert = true
			viewModel.isLoading = .failed
			print("ERROR: invalid url")
		} catch FetchUserError.invalidResponse {
			viewModel.showAlert = true
			viewModel.isLoading = .failed
			print("ERROR: invalid response")
		} catch FetchUserError.notFound {
			viewModel.showAlert = true
			viewModel.isLoading = .failed
			print("ERROR: users not found")
		} catch FetchUserError.invalidData {
			viewModel.showAlert = true
			viewModel.isLoading = .failed
			print("ERROR: invalid data")
		} catch {
			viewModel.showAlert = true
			viewModel.isLoading = .failed
			print("Error loading users data: \(error.localizedDescription)")
		}
	}
}

#Preview {
	UserListView(filter: FILTER_OPTIONS.first!, sortOrder: [])
}
