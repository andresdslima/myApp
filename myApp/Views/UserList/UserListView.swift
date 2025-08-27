import SwiftUI
import SwiftData

struct UserListView: View {
	@Environment(\.modelContext) var modelContext
	@Query var users: [User]
	@State private var viewModel = ViewModel()
	//  @State private var showAlert = false
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
					//					.onMove { indexSet, destination in
			    /// 					Need to use @State
					//						users.move(fromOffsets: indexSet, toOffset: destination)
					//					}
				}
			} else if viewModel.isLoading != .loading {
				EmptyUsersView(loadData: loadData)
			}
		}
		.alert(viewModel.alertError?.errorDescription ?? DEFAULT_ALERT_MESSAGE,
					 isPresented: $viewModel.showAlert,
					 presenting: viewModel.alertError
		) { error in
			///MARK: Simple example of conditional alert
			if error == .invalidUrl {
				TextField("New URL", text: .constant(""))
				
				Button("Retry") { Task { await loadData() } }
				
				Button("Cancel", role: .cancel) { }
			}
		} message: { error in
			Text(error.failureReason)
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
	
	func handleUserError(_ error: FetchUserError) {
		viewModel.alertError = error
		viewModel.showAlert = true
		viewModel.isLoading = .failed
		
		switch error {
		case .invalidUrl:
			print("ERROR: invalid url.")
		case .invalidResponse:
			print("ERROR: invalid response.")
		case .notFound:
			print("ERROR: users not found.")
		case .invalidData:
			print("ERROR: invalid data.")
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
			viewModel.alertError = nil
			viewModel.showAlert = true
			viewModel.isLoading = .failed
			print("Error loading users data: \(error.localizedDescription)")
		}
	}
}

#Preview {
	UserListView(filter: FILTER_OPTIONS.first!, sortOrder: [])
		.preferredColorScheme(.dark)
}
