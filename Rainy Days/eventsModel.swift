//
//  json_rdApp.swift
//  json rd
//
//  Created by Desislava Andonova on 09/03/2024.
//
import Foundation
import SwiftUI
import UIKit

struct Event: Codable, Identifiable {
    var id = UUID()
    var eventName: String
    var eventDateTime: Date
    var eventDescription: String
    var location: String
    var price: Double
    var gender: String
    var minAge: Int
    var maxAge: Int
    var image: String // You can use UIImage or Data if you want to store the actual image
    // Add other properties as needed
}

class DataManager {
    static let shared = DataManager()

    private var events: [Event] = []

    private init() {
        // Load events from JSON file on app launch
        loadEvents()
    }

    func addEvent(_ event: Event) {
        events.append(event)
        saveEvents()
    }

    func getEvents() -> [Event] {
        return events
    }

    private func saveEvents() {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(events)
            if let filePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("events.json") {
                try data.write(to: filePath)
            }
        } catch {
            print("Error saving events: \(error.localizedDescription)")
        }
    }

    private func loadEvents() {
        if let filePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("events.json") {
            do {
                let data = try Data(contentsOf: filePath)
                let decoder = JSONDecoder()
                events = try decoder.decode([Event].self, from: data)
            } catch {
                print("Error loading events: \(error.localizedDescription)")
            }
        }
    }
}
