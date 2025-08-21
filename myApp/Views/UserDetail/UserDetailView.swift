import SwiftUI

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
		.navigationBarTitleDisplayMode(.inline)
		.scrollBounceBehavior(.basedOnSize)
	}
}

#Preview {
	UserDetailView(user: .example)
		.preferredColorScheme(.dark)
}
