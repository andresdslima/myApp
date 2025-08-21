import SwiftUI
import SwiftData

struct UserListView: View {
	@Environment(\.modelContext) var modelContext
	@Query var users: [User]
	@State private var showAlert = false
	@State private var isLoading = false
	
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
			} else if !isLoading {
				EmptyListView()
			}
			
			
			if isLoading {
				ProgressView()
					.scaleEffect(3)
			}
		}
		.alert("Something went wrong", isPresented: $showAlert) {} message: {
			Text("Please make sure you're connected to the internet or try again later.")
		}
		.task { await loadData() }
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
		isLoading = true
		if !users.isEmpty {
			isLoading = false
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
				modelContext.insert(user)
			}
			isLoading = false
		} catch {
			showAlert = true
			isLoading = false
			print("Error fetching users: \(error.localizedDescription)")
		}
	}
	
	func loadData() async {
		do {
			try await fetchUsers()
		} catch {
			showAlert = true
			isLoading = false
			print("Error loading users data: \(error.localizedDescription)")
		}
	}
}

#Preview {
	UserListView(filter: FILTER_OPTIONS.first!, sortOrder: [])
}
