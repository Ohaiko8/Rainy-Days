//
//  json_rdApp.swift
//  json rd
//
//  Created by Desislava Andonova on 09/03/2024.
//
import Foundation
import SwiftUI
import UIKit
import Combine

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
    var image: String
}
    
    class DataManager: ObservableObject {
        static let shared = DataManager()
        
        @Published var events: [Event] = []
        
        private init() {
            loadEvents()
        }
        
        
        func addEvent(_ event: Event) {
            events.append(event)
            saveEvents()
        }
        
        func getEvents() -> [Event] {
            return events
        }
        
        func saveEvents() {
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
        
        func loadEvents() {
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
        func removeEvent(withId id: UUID) {
            if let index = events.firstIndex(where: { $0.id == id }) {
                events.remove(at: index)
                saveEvents() // Save the updated list to persist the changes
            }
        }
    }

