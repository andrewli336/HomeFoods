//
//  PreorderView.swift
//  HomeFoods
//
//  Created by Andrew Li on 1/11/25.
//

import SwiftUI

struct PreorderView: View {
    @State private var selectedDate: Date = Date() // Tracks the selected date
    let highlightedDates: [Date] // Dates to highlight

    var body: some View {
        VStack(spacing: 20) {
            Text("Select a Preorder Date")
                .font(.headline)

            CustomCalendarView(selectedDate: $selectedDate, highlightedDates: highlightedDates)
                .padding()

            Text("You selected: \(formattedDate(selectedDate))")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding()
    }

    // Format the selected date for display
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: date)
    }
}

struct CustomCalendarView: View {
    @Binding var selectedDate: Date
    let highlightedDates: [Date]
    private let calendar = Calendar.current
    private let daysOfWeek = Calendar.current.shortWeekdaySymbols

    var body: some View {
        VStack {
            // Weekday headers
            HStack {
                ForEach(daysOfWeek, id: \.self) { day in
                    Text(day)
                        .font(.subheadline)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.gray)
                }
            }

            // Calendar grid
            let dates = generateDates()
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
                ForEach(dates, id: \.self) { date in
                    CalendarDateView(
                        date: date,
                        isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                        isHighlighted: highlightedDates.contains { calendar.isDate($0, inSameDayAs: date) }
                    )
                    .onTapGesture {
                        selectedDate = date // Update selected date on tap
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
    }

    // Generate all dates for the current month
    private func generateDates() -> [Date] {
        guard let monthRange = calendar.range(of: .day, in: .month, for: Date()) else {
            return []
        }
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: Date()))!
        return monthRange.compactMap { day -> Date? in
            calendar.date(byAdding: .day, value: day - 1, to: startOfMonth)
        }
    }
}

struct CalendarDateView: View {
    let date: Date
    let isSelected: Bool
    let isHighlighted: Bool
    private let calendar = Calendar.current

    var body: some View {
        Text("\(calendar.component(.day, from: date))")
            .font(.body)
            .frame(maxWidth: .infinity, maxHeight: 40)
            .background(
                isSelected ? Color.blue :
                isHighlighted ? Color.green.opacity(0.3) :
                Color.clear
            )
            .cornerRadius(5)
            .foregroundColor(isSelected ? .white : .black)
    }
}

#Preview {
    let highlightedDates = [
        Calendar.current.date(byAdding: .day, value: 1, to: Date())!,
        Calendar.current.date(byAdding: .day, value: 3, to: Date())!,
        Calendar.current.date(byAdding: .day, value: 5, to: Date())!
    ]

    PreorderView(highlightedDates: highlightedDates)
}
