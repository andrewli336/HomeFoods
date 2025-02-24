//
//  NotificationView.swift
//  HomeFoods
//
//  Created by Andrew Li on 2/23/25.
//

import SwiftUI

// NotificationView to display notifications
struct NotificationView: View {
    @EnvironmentObject var notificationViewModel: NotificationViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List {
                ForEach(notificationViewModel.notifications) { notification in
                    NotificationRow(notification: notification)
                        .onTapGesture {
                            notificationViewModel.markAsRead(notification)
                        }
                }
            }
            .navigationTitle("Notifications")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Mark All Read") {
                        notificationViewModel.markAllAsRead()
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// NotificationRow for individual notifications
struct NotificationRow: View {
    let notification: AppNotification
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: iconForType(notification.type))
                    .foregroundColor(colorForType(notification.type))
                Text(notification.title)
                    .font(.headline)
                Spacer()
                if !notification.isRead {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 8, height: 8)
                }
            }
            
            Text(notification.message)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text(notification.timestamp, style: .relative)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
        .opacity(notification.isRead ? 0.8 : 1)
    }
    
    private func iconForType(_ type: AppNotification.NotificationType) -> String {
        switch type {
        case .order:
            return "bag.fill"
        case .system:
            return "gear.fill"
        case .promotion:
            return "tag.fill"
        }
    }
    
    private func colorForType(_ type: AppNotification.NotificationType) -> Color {
        switch type {
        case .order:
            return .blue
        case .system:
            return .gray
        case .promotion:
            return .green
        }
    }
}

// Modified ContentView notification button
struct NotificationButton: View {
    @EnvironmentObject var notificationViewModel: NotificationViewModel
    @State private var showingNotifications = false
    
    var body: some View {
        Button(action: {
            showingNotifications = true
        }) {
            ZStack(alignment: .topTrailing) {
                Image(systemName: "bell")
                    .foregroundColor(.black)
                
                if notificationViewModel.unreadCount > 0 {
                    Text("\(notificationViewModel.unreadCount)")
                        .font(.caption2)
                        .padding(4)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                        .offset(x: 10, y: -10)
                }
            }
        }
        .sheet(isPresented: $showingNotifications) {
            NotificationView()
        }
    }
}

