//
//  ChefDashboardView.swift
//  HomeFoods
//
//  Created by Andrew Li on 1/11/25.
//

import SwiftUI

struct ChefDashboardView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @State private var selectedDate: Date = Date()
    @State private var showingAddFoodSheet = false
    @State private var schedule: PreorderSchedule?
    @State private var isLoading = true
    
    var highlightedDates: [Date] {
        guard let schedule = schedule else { return [] }
        return schedule.dates.compactMap { Date.fromScheduleKey($0.key) }
    }
    
    var foodsForSelectedDate: [PreorderFood] {
        guard let schedule = schedule else { return [] }
        return schedule.dates[selectedDate.scheduleKey] ?? []
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Select a Date")
                    .font(.headline)
                
                CustomCalendarView(selectedDate: $selectedDate, highlightedDates: highlightedDates)
                    .padding()
                
                if isLoading {
                    ProgressView()
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            if foodsForSelectedDate.isEmpty {
                                emptyScheduleView
                            } else {
                                preorderFoodList(foods: foodsForSelectedDate)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Preorder Schedule")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Add Food") {
                        showingAddFoodSheet = true
                    }
                }
            }
            .sheet(isPresented: $showingAddFoodSheet) {
                AddPreorderFoodView(selectedDate: selectedDate) { newFood in
                    addFoodToSchedule(newFood)
                }
            }
            .onAppear {
                loadSchedule()
            }
        }
    }
    
    private func preorderFoodList(foods: [PreorderFood]) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Available Foods")
                .font(.headline)
            
            ForEach(foods, id: \.foodItemId) { food in
                PreorderFoodRow(food: food) { updatedFood in
                    updateFoodInSchedule(updatedFood)
                } onDelete: {
                    deleteFoodFromSchedule(food)
                }
            }
        }
    }
    
    private var emptyScheduleView: some View {
        VStack(spacing: 12) {
            Text("No foods scheduled for \(formattedDate(selectedDate))")
                .foregroundColor(.secondary)
            Button("Add Food") {
                showingAddFoodSheet = true
            }
            .buttonStyle(.bordered)
        }
        .frame(maxWidth: .infinity, minHeight: 200)
    }
    
    private func loadSchedule() {
        guard let kitchenId = viewModel.currentUser?.kitchenId else {
            isLoading = false
            return
        }
        
        viewModel.fetchPreorderSchedule(kitchenId: kitchenId) { fetchedSchedule in
            DispatchQueue.main.async {
                schedule = fetchedSchedule ?? PreorderSchedule(dates: [:])
                isLoading = false
            }
        }
    }
    
    private func addFoodToSchedule(_ food: PreorderFood) {
        var updatedSchedule = schedule ?? PreorderSchedule(dates: [:])
        let dateKey = selectedDate.scheduleKey
        var dateFoods = updatedSchedule.dates[dateKey] ?? []
        dateFoods.append(food)
        updatedSchedule.dates[dateKey] = dateFoods
        
        saveSchedule(updatedSchedule)
    }
    
    private func updateFoodInSchedule(_ updatedFood: PreorderFood) {
        var updatedSchedule = schedule ?? PreorderSchedule(dates: [:])
        let dateKey = selectedDate.scheduleKey
        
        if var foods = updatedSchedule.dates[dateKey] {
            if let index = foods.firstIndex(where: { $0.foodItemId == updatedFood.foodItemId }) {
                foods[index] = updatedFood
                updatedSchedule.dates[dateKey] = foods
                saveSchedule(updatedSchedule)
            }
        }
    }
    
    private func deleteFoodFromSchedule(_ food: PreorderFood) {
        var updatedSchedule = schedule ?? PreorderSchedule(dates: [:])
        let dateKey = selectedDate.scheduleKey
        
        if var foods = updatedSchedule.dates[dateKey] {
            foods.removeAll { $0.foodItemId == food.foodItemId }
            updatedSchedule.dates[dateKey] = foods
            saveSchedule(updatedSchedule)
        }
    }
    
    private func saveSchedule(_ newSchedule: PreorderSchedule) {
        guard let kitchenId = viewModel.currentUser?.kitchenId else { return }
        
        viewModel.updatePreorderSchedule(kitchenId: kitchenId, schedule: newSchedule) { success in
            if success {
                schedule = newSchedule
            }
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: date)
    }
}

// Updated AddPreorderFoodView to work with dates instead of weekdays
struct AddPreorderFoodView: View {
    @EnvironmentObject var viewModel: AppViewModel
    let selectedDate: Date
    let onSave: (PreorderFood) -> Void
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedFood: FoodItem?
    @State private var availableTimes: [String] = []
    @State private var foodItems: [FoodItem] = []
    @State private var isLoading = true
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Food Item")) {
                    if isLoading {
                        ProgressView()
                    } else if foodItems.isEmpty {
                        Text("No food items available")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(foodItems, id: \.id) { food in
                            HStack {
                                if let imageUrl = food.imageUrl {
                                    AsyncImage(url: URL(string: imageUrl)) { image in
                                        image.resizable()
                                            .scaledToFill()
                                            .frame(width: 50, height: 50)
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                    } placeholder: {
                                        Color.gray.opacity(0.2)
                                            .frame(width: 50, height: 50)
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                    }
                                } else {
                                    Color.gray.opacity(0.2)
                                        .frame(width: 50, height: 50)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                                
                                VStack(alignment: .leading) {
                                    Text(food.name)
                                        .font(.headline)
                                    Text("$\(String(format: "%.2f", food.cost))")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                if selectedFood?.id == food.id {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.blue)
                                }
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedFood = food
                            }
                        }
                    }
                }
                
                if selectedFood != nil {
                    Section(header: Text("Available Times")) {
                        TimeSlotPicker(timeSlots: $availableTimes)
                    }
                }
            }
            .navigationTitle("Add Food for \(formattedDate(selectedDate))")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    guard let selectedFood = selectedFood else { return }
                    let newFood = PreorderFood(
                        foodItemId: selectedFood.id ?? "",
                        availableTimes: availableTimes.sorted()
                    )
                    onSave(newFood)
                    presentationMode.wrappedValue.dismiss()
                }
                .disabled(selectedFood == nil || availableTimes.isEmpty)
            )
        }
        .onAppear {
            loadFoodItems()
        }
    }
    
    private func loadFoodItems() {
        guard let kitchenId = viewModel.currentUser?.kitchenId else {
            isLoading = false
            return
        }
        
        viewModel.fetchFoodItems(for: kitchenId) { items in
            DispatchQueue.main.async {
                self.foodItems = items
                self.isLoading = false
            }
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: date)
    }
}

struct TimeSlotPicker: View {
    @Binding var timeSlots: [String]
    @State private var showingAddTimeSheet = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            FlowLayout(spacing: 8) {
                ForEach(timeSlots.indices, id: \.self) { index in
                    timeSlotChip(timeSlots[index]) {
                        timeSlots.remove(at: index)
                    }
                }
                
                Button(action: { showingAddTimeSheet = true }) {
                    Label("Add Time", systemImage: "plus.circle.fill")
                        .font(.subheadline)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .clipShape(Capsule())
                }
            }
        }
        .sheet(isPresented: $showingAddTimeSheet) {
            AddTimeSlotView { newSlot in
                if !timeSlots.contains(newSlot) {
                    timeSlots.append(newSlot)
                }
            }
        }
    }
    
    func timeSlotChip(_ slot: String, onDelete: @escaping () -> Void) -> some View {
        HStack(spacing: 4) {
            Text(slot)
            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.blue.opacity(0.5))
            }
        }
        .font(.subheadline)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.blue.opacity(0.1))
        .foregroundColor(.blue)
        .clipShape(Capsule())
    }
}

struct AddTimeSlotView: View {
    @Environment(\.presentationMode) var presentationMode
    let onSave: (String) -> Void
    
    @State private var startHour = 9
    @State private var startMinute = 0
    @State private var endHour = 10
    @State private var endMinute = 0
    
    let hours = Array(6...23)
    let minutes = [0, 15, 30, 45]
    
    var timeSlot: String {
        String(format: "%02d:%02d-%02d:%02d", startHour, startMinute, endHour, endMinute)
    }
    
    var isValidTimeSlot: Bool {
        let start = startHour * 60 + startMinute
        let end = endHour * 60 + endMinute
        return end > start
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Start Time")) {
                    HStack {
                        Picker("Hour", selection: $startHour) {
                            ForEach(hours, id: \.self) { hour in
                                Text("\(hour):00").tag(hour)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 100)
                        
                        Picker("Minute", selection: $startMinute) {
                            ForEach(minutes, id: \.self) { minute in
                                Text("\(minute)").tag(minute)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 100)
                    }
                }
                
                Section(header: Text("End Time")) {
                    HStack {
                        Picker("Hour", selection: $endHour) {
                            ForEach(hours, id: \.self) { hour in
                                Text("\(hour):00").tag(hour)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 100)
                        
                        Picker("Minute", selection: $endMinute) {
                            ForEach(minutes, id: \.self) { minute in
                                Text("\(minute)").tag(minute)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 100)
                    }
                }
                
                Section {
                    HStack {
                        Text("Time Slot:")
                        Spacer()
                        Text(timeSlot)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Add Time Slot")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Add") {
                    onSave(timeSlot)
                    presentationMode.wrappedValue.dismiss()
                }
                .disabled(!isValidTimeSlot)
            )
        }
    }
}


struct EditPreorderFoodView: View {
    let food: PreorderFood
    let onSave: (PreorderFood) -> Void
    @Environment(\.presentationMode) var presentationMode
    @State private var availableTimes: [String]
    
    init(food: PreorderFood, onSave: @escaping (PreorderFood) -> Void) {
        self.food = food
        self.onSave = onSave
        _availableTimes = State(initialValue: food.availableTimes)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Available Times")) {
                    TimeSlotPicker(timeSlots: $availableTimes)
                }
            }
            .navigationTitle("Edit Time Slots")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    let updatedFood = PreorderFood(
                        foodItemId: food.foodItemId,
                        availableTimes: availableTimes.sorted()
                    )
                    onSave(updatedFood)
                    presentationMode.wrappedValue.dismiss()
                }
                .disabled(availableTimes.isEmpty)
            )
        }
    }
}

struct PreorderFoodRow: View {
    @EnvironmentObject var viewModel: AppViewModel
    let food: PreorderFood
    let onUpdate: (PreorderFood) -> Void
    let onDelete: () -> Void
    @State private var showingEditSheet = false
    @State private var foodItem: FoodItem?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                // Food Image
                AsyncImage(url: URL(string: foodItem?.imageUrl ?? "")) { image in
                    image.resizable()
                        .scaledToFill()
                        .frame(width: 60, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                } placeholder: {
                    Color.gray.opacity(0.2)
                        .frame(width: 60, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(foodItem?.name ?? "Loading...")
                        .font(.headline)
                    Text(foodItem?.description ?? "")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                HStack(spacing: 12) {
                    Button(action: { showingEditSheet = true }) {
                        Image(systemName: "pencil")
                            .foregroundColor(.blue)
                    }
                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Available times:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                FlowLayout(spacing: 8) {
                    ForEach(food.availableTimes, id: \.self) { time in
                        Text(time)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .clipShape(Capsule())
                    }
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
        .sheet(isPresented: $showingEditSheet) {
            EditPreorderFoodView(food: food, onSave: onUpdate)
        }
        .onAppear {
            loadFoodItem()
        }
    }
    
    private func loadFoodItem() {
        guard let kitchenId = viewModel.currentUser?.kitchenId else { return }
        
        viewModel.fetchFoodItems(for: kitchenId) { items in
            DispatchQueue.main.async {
                self.foodItem = items.first(where: { $0.id == food.foodItemId })
            }
        }
    }
}

// Helper view for flowing layout of time slots
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.width ?? 0, subviews: subviews, spacing: spacing)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
            let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
            for (index, placement) in result.placements.enumerated() {
                // Create a new CGPoint that adds the offset to the bounds origin
                let point = CGPoint(
                    x: placement.offset.x + bounds.origin.x,
                    y: placement.offset.y + bounds.origin.y
                )
                subviews[index].place(at: point, proposal: placement.proposal)
            }
        }
    
    struct FlowResult {
        var placements: [(offset: CGPoint, proposal: ProposedViewSize)]
        var size: CGSize
        
        init(in width: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var placements = [(offset: CGPoint, proposal: ProposedViewSize)]()
            var mainPosition: CGFloat = 0
            var crossPosition: CGFloat = 0
            var lineHeight: CGFloat = 0
            var maxWidth: CGFloat = 0
            
            for subview in subviews {
                let idealSize = subview.sizeThatFits(.unspecified)
                if mainPosition + idealSize.width > width, mainPosition > 0 {
                    mainPosition = 0
                    crossPosition += lineHeight + spacing
                    lineHeight = 0
                }
                
                placements.append((
                    offset: CGPoint(x: mainPosition, y: crossPosition),
                    proposal: ProposedViewSize(width: idealSize.width, height: idealSize.height)
                ))
                
                lineHeight = max(lineHeight, idealSize.height)
                mainPosition += idealSize.width + spacing
                maxWidth = max(maxWidth, mainPosition)
            }
            
            self.placements = placements
            self.size = CGSize(width: maxWidth, height: crossPosition + lineHeight)
        }
    }
}


