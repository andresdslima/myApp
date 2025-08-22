import SwiftUI
import SwiftData

@main
struct myApp: App {
	let container: ModelContainer = {
		do {
			let schema = Schema([User.self])
			let container = try! ModelContainer(for: schema, configurations: [])
			return container
		} catch {}
	}()
	
	var body: some Scene {
		WindowGroup {
			ContentView()
		}
		.modelContainer(for: [User.self])
		//.modelContainer(container)
	}
}
