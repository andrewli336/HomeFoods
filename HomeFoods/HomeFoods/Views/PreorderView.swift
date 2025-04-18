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
        guard let schedule = schedule else {
            print("⚠️ No schedule available for highlighted dates")
            return []
        }
        
        let dates = schedule.dates.compactMap { Date.fromScheduleKey($0.key) }
        print("🗓 Highlighted dates count: \(dates.count)")
        dates.forEach { print("   📆 Highlighted date: \($0.scheduleKey)") }
        return dates
    }

    var availableFoodItems: [PreorderFood] {
        guard let schedule = schedule else {
            print("⚠️ No schedule available for food items")
            return []
        }
        
        let dateKey = selectedDate.scheduleKey
        print("🔎 Looking for foods on date: \(dateKey)")
        let foods = schedule.dates[dateKey] ?? []
        print("🍽 Found \(foods.count) foods for \(dateKey)")
        return foods
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
                                PreorderFoodItemRow(
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
        
        let kitchenId = kitchen.id ?? ""
        
        viewModel.fetchPreorderSchedule(kitchenId: kitchenId) { fetchedSchedule in
            DispatchQueue.main.async {
                self.schedule = fetchedSchedule ?? PreorderSchedule(dates: [:])
                
                self.viewModel.fetchFoodItems(for: kitchenId) { items in
                    DispatchQueue.main.async {
                        self.foodItems = items
                        self.isLoading = false
                    }
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
                if let imageUrl = foodItem.imageUrl {
                    AsyncImage(url: URL(string: imageUrl)) { image in
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
                } else {
                    Color.gray.opacity(0.2)
                        .frame(width: 80, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(foodItem.name)
                        .font(.headline)
                    Text(foodItem.description ?? "")
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
    @State private var currentMonth: Date
    private let calendar = Calendar.current
    private let daysOfWeek = Calendar.current.shortWeekdaySymbols
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()

    init(selectedDate: Binding<Date>, highlightedDates: [Date]) {
        self._selectedDate = selectedDate
        self.highlightedDates = highlightedDates
        self._currentMonth = State(initialValue: selectedDate.wrappedValue)
    }

    var body: some View {
        VStack(spacing: 20) {
            // Month navigation header
            HStack {
                Button(action: previousMonth) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                Text(dateFormatter.string(from: currentMonth))
                    .font(.title3)
                    .bold()
                
                Spacer()
                
                Button(action: nextMonth) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal)

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
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                ForEach(dates, id: \.self) { date in
                    if calendar.component(.month, from: date) == calendar.component(.month, from: currentMonth) {
                        CalendarDateView(
                            date: date,
                            isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                            isHighlighted: highlightedDates.contains { calendar.isDate($0, inSameDayAs: date) }
                        )
                        .onTapGesture {
                            selectedDate = date
                        }
                    } else {
                        // Empty view for dates outside current month
                        Text("\(calendar.component(.day, from: date))")
                            .font(.body)
                            .frame(maxWidth: .infinity, maxHeight: 40)
                            .foregroundColor(.gray.opacity(0.3))
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
    }

    private func nextMonth() {
        if let newDate = calendar.date(byAdding: .month, value: 1, to: currentMonth) {
            currentMonth = newDate
        }
    }

    private func previousMonth() {
        if let newDate = calendar.date(byAdding: .month, value: -1, to: currentMonth) {
            currentMonth = newDate
        }
    }

    private func generateDates() -> [Date] {
        let components = calendar.dateComponents([.year, .month], from: currentMonth)
        guard let startOfMonth = calendar.date(from: components),
              let range = calendar.range(of: .day, in: .month, for: startOfMonth) else {
            return []
        }

        // Get the first day of the month
        let firstDayOfMonth = calendar.component(.weekday, from: startOfMonth)
        
        // Calculate days from previous month to show
        let daysFromPreviousMonth = firstDayOfMonth - 1
        
        // Get the last day of the month
        guard let lastDayOfMonth = calendar.date(byAdding: .day, value: range.count - 1, to: startOfMonth) else {
            return []
        }
        
        // Calculate remaining days to show from next month to complete the grid
        let lastWeekday = calendar.component(.weekday, from: lastDayOfMonth)
        let daysFromNextMonth = 7 - lastWeekday
        
        // Generate all dates
        var dates: [Date] = []
        
        // Add days from previous month
        if let firstDate = calendar.date(byAdding: .day, value: -daysFromPreviousMonth, to: startOfMonth) {
            for dayOffset in 0..<daysFromPreviousMonth {
                if let date = calendar.date(byAdding: .day, value: dayOffset, to: firstDate) {
                    dates.append(date)
                }
            }
        }
        
        // Add days from current month
        for dayOffset in 0..<range.count {
            if let date = calendar.date(byAdding: .day, value: dayOffset, to: startOfMonth) {
                dates.append(date)
            }
        }
        
        // Add days from next month
        if let firstDateOfNextMonth = calendar.date(byAdding: .day, value: 1, to: lastDayOfMonth) {
            for dayOffset in 0..<daysFromNextMonth {
                if let date = calendar.date(byAdding: .day, value: dayOffset, to: firstDateOfNextMonth) {
                    dates.append(date)
                }
            }
        }
        
        return dates
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
