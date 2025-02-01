//
//  AutocompleteManager.swift
//  HomeFoods
//
//  Created by Andrew Li on 2/1/25.
//

import MapKit
import Combine

class AutocompleteManager: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
    @Published var searchQuery = ""
    @Published var searchResults: [MKLocalSearchCompletion] = []

    private var cancellables = Set<AnyCancellable>()
    private let searchCompleter = MKLocalSearchCompleter()

    override init() {
        super.init()  // ✅ Call NSObject's initializer
        searchCompleter.resultTypes = .address
        searchCompleter.delegate = self

        // 📌 Automatically update results when query changes
        $searchQuery
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] query in
                guard let self = self else { return }
                if !query.isEmpty {
                    self.searchCompleter.queryFragment = query
                } else {
                    self.searchResults = []
                }
            }
            .store(in: &cancellables)
    }

    // ✅ Delegate method: Called when new autocomplete results are available
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        DispatchQueue.main.async {
            self.searchResults = completer.results
        }
    }

    // ✅ Delegate method: Handle autocomplete errors
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("🔴 Autocomplete error: \(error.localizedDescription)")
    }
}
