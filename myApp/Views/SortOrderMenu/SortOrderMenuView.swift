import SwiftUI

struct SortOrderMenuView: View {
	@Binding var sortOrder: [SortDescriptor<User>]
	@Binding var showReverse: Bool
	@Binding var selectedSort: String
	
	var body: some View {
		Menu("Sort", systemImage: "arrow.up.arrow.down") {
			Button {
				if selectedSort == SORT_OPTIONS[0] {
					showReverse.toggle()
				} else {
					selectedSort = SORT_OPTIONS[0]
					showReverse = false
				}
				sortOrder = [
					SortDescriptor(\User.name, order: showReverse ? .reverse : .forward),
					SortDescriptor(\User.registered, order: showReverse ? .reverse : .forward),
				]
			} label: {
				HStack {
					Text(SORT_OPTIONS[0])
					selectedSort == SORT_OPTIONS[0] ? Image(systemName: "checkmark") : nil
				}
			}
			
			Button {
				if selectedSort == SORT_OPTIONS[1] {
					showReverse.toggle()
				} else {
					selectedSort = SORT_OPTIONS[1]
					showReverse = true
				}
				sortOrder = [
					SortDescriptor(\User.registered, order: showReverse ? .reverse : .forward),
					SortDescriptor(\User.name, order: showReverse ? .reverse : .forward),
				]
			} label: {
				HStack {
					Text(SORT_OPTIONS[1])
					selectedSort == SORT_OPTIONS[1] ? Image(systemName: "checkmark") : nil
				}
			}
		}
	}
}

#Preview {
	let sortOrder: Binding<[SortDescriptor<User>]> = .constant([SortDescriptor(\User.name)])
	let showReverse: Binding<Bool> = .constant(false)
	let selectedSort: Binding<String> = .constant(SORT_OPTIONS.first!)
	
	SortOrderMenuView(sortOrder: sortOrder, showReverse: showReverse, selectedSort: selectedSort)
}
