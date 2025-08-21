import SwiftUI
import SwiftData

@main
struct myApp: App {
		var body: some Scene {
				WindowGroup {
						ContentView()
				}
				.modelContainer(for: User.self)
		}
}
