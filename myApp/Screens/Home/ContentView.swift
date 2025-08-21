import SwiftUI
import SwiftData

struct ContentView: View {
	@Query(filter: #Predicate<User> { user in
		user.isActive
	}, sort: \User.name) var users: [User]
	
	@State private var filter = FILTER_OPTIONS[0]
	@State private var sortOrder = [
		SortDescriptor(\User.name),
		SortDescriptor(\User.registered, order: .reverse),
	]
	
	@State private var showReverse = false
	@State private var selectedSort = SORT_OPTIONS.first!
	
	var body: some View {
		NavigationStack {
			UserListView(
				filter: filter,
				sortOrder: sortOrder
			)
			.navigationTitle("Users")
			.preferredColorScheme(.dark)
			.toolbarBackground(.black)
			.scrollBounceBehavior(.basedOnSize)
			.toolbar {
				if !users.isEmpty {
					ToolbarItem(placement: .topBarLeading) {
						EditButton()
					}
					
					ToolbarItemGroup(placement: .topBarTrailing) {
						Menu(
							filter == FILTER_OPTIONS[1] ? FILTER_OPTIONS[1] : filter == FILTER_OPTIONS[2] ? FILTER_OPTIONS[2] : FILTER_OPTIONS[0]
						) {
							Picker("Filter", selection: $filter) {
								Text(FILTER_OPTIONS[0])
									.tag(FILTER_OPTIONS[0])
								
								Text(FILTER_OPTIONS[1])
									.tag(FILTER_OPTIONS[1])
								
								Text(FILTER_OPTIONS[2])
									.tag(FILTER_OPTIONS[2])
							}
						}
						
						SortOrderMenuView(
							sortOrder: $sortOrder,
							showReverse: $showReverse,
							selectedSort: $selectedSort
						)
					}
				}
			}
		}
	}
}

#Preview {
	ContentView()
}
