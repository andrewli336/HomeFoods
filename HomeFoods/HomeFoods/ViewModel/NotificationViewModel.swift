//
//  NotificationViewModel.swift
//  HomeFoods
//
//  Created by Andrew Li on 2/23/25.
//
import SwiftUI

struct AppNotification: Identifiable {
    let id = UUID()
    let title: String
    let message: String
    let timestamp: Date
    var isRead: Bool
    let type: NotificationType
    
    enum NotificationType {
        case order
        case system
        case promotion
    }
}

// NotificationViewModel to manage notifications
class NotificationViewModel: ObservableObject {
    @Published var notifications: [AppNotification] = []
    @Published var unreadCount: Int = 0
    
    func addNotification(title: String, message: String, type: AppNotification.NotificationType) {
        let notification = AppNotification(
            title: title,
            message: message,
            timestamp: Date(),
            isRead: false,
            type: type
        )
        notifications.insert(notification, at: 0)
        updateUnreadCount()
    }
    
    func markAsRead(_ notification: AppNotification) {
        if let index = notifications.firstIndex(where: { $0.id == notification.id }) {
            notifications[index].isRead = true
            updateUnreadCount()
        }
    }
    
    func markAllAsRead() {
        notifications = notifications.map { notification in
            var updatedNotification = notification
            updatedNotification.isRead = true
            return updatedNotification
        }
        updateUnreadCount()
    }
    
    private func updateUnreadCount() {
        unreadCount = notifications.filter { !$0.isRead }.count
    }
}

