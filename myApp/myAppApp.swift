import SwiftUI
import SwiftData

@main
struct myApp: App {
	let container: ModelContainer = {
		let schema = Schema([User.self])
		do {
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
