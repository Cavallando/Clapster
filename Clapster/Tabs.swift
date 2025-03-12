import SwiftUI

enum Tab: String, CaseIterable, Identifiable {
    case events
    case clap
    case about
    case play

    var id: Self { self }
}


// Environment object to share selected tab across the app
class TabSelection: ObservableObject {
    init(selection: Binding<Tab>) {
        self._selection = selection
    }
    
    private var _selection: Binding<Tab>
    
    func select(tab: Tab) {
        _selection.wrappedValue = tab
    }
}

// ViewModel to hold the tab selection state
class TabSelectionViewModel: ObservableObject {
    @Published var selectedTab: Tab = .play
}
