import SwiftUI

struct EventDetailView: View {
    var event: Event

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Replace with the actual image from the event model
                Image(event.image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 200)
                    .clipped()

                Text(event.eventName)
                    .font(.title)
                    .fontWeight(.bold)

                HStack {
                    Image(systemName: "location")
                    Text(event.location)
                }

                HStack {
                    Image(systemName: "calendar")
                    Text("Date: \(formattedDate(event.eventDateTime))")
                }

                HStack {
                    Image(systemName: "clock")
                    Text("Time: \(formattedTimeRange(event.eventDateTime))")
                }

                Text(event.eventDescription)

                HStack {
                    Text("Organized by:")
                        .font(.headline)
                    Text("May") // Replace with the actual organizer
                }

                // Add the profile image for May here

                Button(action: {
                    // Add action to send a message to the host
                }) {
                    Text("Send Message to May")
                        .foregroundColor(.blue)
                }

                HStack {
                    Text("Price:")
                        .font(.headline)
                    Text("\(formattedPrice(event.price))")
                }

                HStack(alignment: .bottom) {
                    Spacer()
                    Button(action: {
                        // Add action to mark user attendance
                    }) {
                        Text("I'm Attending")
                            .foregroundColor(.white)
                            .fontWeight(.bold)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                }
            }
            .padding()
        }
        .navigationBarTitle("Event Details")
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: date)
    }

    private func formattedTimeRange(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return "\(formatter.string(from: date)) - \(formatter.string(from: date.addingTimeInterval(3 * 60 * 60)))"
    }

    private func formattedPrice(_ price: Double) -> String {
        return price == 0 ? "Free" : "$\(price)"
    }
}

struct EventDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let event = Event(
            eventName: "Guitar Competition",
            eventDateTime: Date(),
            eventDescription: "Showcase your guitar skills in this exciting competition! Join us for an evening filled with music, talent, and friendly competition.",
            location: "123 Main Street, Cityville",
            price: 0,
            gender: "All Welcome",
            minAge: 18,
            maxAge: 30,
            image: "guitar_competition_image"
        )
        return EventDetailView(event: event)
    }
}



