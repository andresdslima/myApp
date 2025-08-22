import SwiftUI

///MARK: We could also edit the selected User here if needed (using @Bindable var user: User). In that case, I'd recommend to also have a red Cancel button on the toolbar (top left side) - by adding an "onAppear" modifier, we could use @State to get the previous values for all User's attributes and set them back to the previous values if the Cancel button is clicked (SwiftData automatically saves them).
struct UserDetailView: View {
	let user: User
	
	var body: some View {
		ScrollView {
			VStack(alignment: .leading, spacing: 25) {
				Text("Company: \(user.company)")
				
				Text("Age: \(user.age) yo")
				
				Text("Email: \(user.email)")
				
				Text("Address: \(user.address)")
				
				Text(
					"Registered date: \(user.registered.formatted(date: .long, time: .omitted))"
				)
				
				Text(user.about)
				
				Section("Friends:") {
					if user.friends.isEmpty {
						Text("No friends yet.")
							.foregroundStyle(.secondary)
					} else {
						ForEach(user.friends) { friend in
							Label(friend.name, systemImage: "person")
								.padding(.vertical, 2)
						}
					}
				}
			}
			.padding()
		}
		.navigationTitle(user.name)
		.navigationBarTitleDisplayMode(.large)
		.scrollBounceBehavior(.basedOnSize)
	}
}

#Preview {
	UserDetailView(user: .example)
		.preferredColorScheme(.dark)
}
