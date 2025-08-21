import SwiftUI

struct EmptyListView: View {
	var body: some View {
		VStack {
			Text("No users found")
				.padding()
		}
	}
}

#Preview {
	EmptyListView()
}
