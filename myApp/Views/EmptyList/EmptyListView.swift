import SwiftUI

struct EmptyUsersView: View {
	let loadData: () async -> Void
	
	var body: some View {
		ContentUnavailableView {
			Text("No Users found")
				.padding()
		} description: {
			Text("Your list of Users is currently empty. \n Please click on the button below to fetch Users.")
		} actions: {
			Button("Fetch Users") {
				Task {
					await loadData()
				}
			}
			.buttonStyle(.borderedProminent)
			.controlSize(.regular)
		}
		.offset(y: -60)
	}
	
	init(loadData: @escaping () async -> Void) {
		self.loadData = loadData
	}
}
