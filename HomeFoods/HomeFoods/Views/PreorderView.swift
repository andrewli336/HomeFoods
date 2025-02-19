//
//  PreorderView.swift
//  HomeFoods
//
//  Created by Andrew Li on 1/11/25.
//

import SwiftUI
struct PreorderView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @State private var selectedDate: Date = Date()
    @State private var schedule: PreorderSchedule?
    @State private var isLoading = true
    @State private var foodItems: [FoodItem] = []
    
    let kitchen: Kitchen
    
    var highlightedDates: [Date] {
        // Get all dates that have available food items
        guard let schedule = schedule else { return [] }
        return schedule.dates.compactMap { Date.fromScheduleKey($0.key) }
    }
    
    var availableFoodItems: [PreorderFood] {
        guard let schedule = schedule else { return [] }
        return schedule.dates[selectedDate.scheduleKey] ?? []
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Select a Preorder Date")
                .font(.headline)
            
            CustomCalendarView(selectedDate: $selectedDate, highlightedDates: highlightedDates)
                .padding()
            
            if isLoading {
                ProgressView()
            } else if availableFoodItems.isEmpty {
                Text("No food items available for \(formattedDate(selectedDate))")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            } else {
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(availableFoodItems, id: \.foodItemId) { preorderFood in
                            if let foodItem = getFoodItem(id: preorderFood.foodItemId) {
                                PreorderFoodItemView(
                                    foodItem: foodItem,
                                    availableTimes: preorderFood.availableTimes
                                )
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .padding()
        .onAppear {
            loadScheduleAndFoodItems()
        }
    }
    
    private func loadScheduleAndFoodItems() {
        isLoading = true
        
        // Load schedule
        viewModel.fetchPreorderSchedule(kitchenId: kitchen.id ?? "") { fetchedSchedule in
            schedule = fetchedSchedule
            
            // Load food items
            viewModel.fetchFoodItems(for: kitchen.id ?? "") { items in
                DispatchQueue.main.async {
                    foodItems = items
                    isLoading = false
                }
            }
        }
    }
    
    private func getFoodItem(id: String) -> FoodItem? {
        foodItems.first { $0.id == id }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: date)
    }
}

struct PreorderFoodItemView: View {
    let foodItem: FoodItem
    let availableTimes: [String]
    @State private var selectedTime: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                AsyncImage(url: URL(string: foodItem.imageUrl)) { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 80, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                } placeholder: {
                    Color.gray.opacity(0.2)
                        .frame(width: 80, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(foodItem.name)
                        .font(.headline)
                    Text(foodItem.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                    Text("$\(foodItem.cost, specifier: "%.2f")")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
            }
            
            Text("Available Times:")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(availableTimes, id: \.self) { time in
                        Button(action: {
                            selectedTime = time
                        }) {
                            Text(time)
                                .font(.caption)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(selectedTime == time ? Color.blue : Color.blue.opacity(0.1))
                                .foregroundColor(selectedTime == time ? .white : .blue)
                                .clipShape(Capsule())
                        }
                    }
                }
            }
            
            if selectedTime != nil {
                Button(action: {
                    // Add to cart logic here
                }) {
                    Text("Add to Cart")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
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
