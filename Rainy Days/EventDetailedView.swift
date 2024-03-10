import SwiftUI

struct EventDetailView: View {
    var event: Event
    
    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 20) { // Center alignment for the VStack
                // AsyncImage to load and display the image from URL
                AsyncImage(url: URL(string: event.image)) { image in
                    image.resizable()
                } placeholder: {
                    ProgressView()
                }
                .aspectRatio(contentMode: .fill)
                .frame(width: 300, height: 300) // Adjusted for circle size
                .clipShape(Circle())
                .shadow(radius: 10)
                .padding(.top, 20)

                VStack(alignment: .leading, spacing: 10) {
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
                        .padding(.top, 10)

                    Text("Price: \(formattedPrice(event.price))")
                        .padding(.top, 10)

                    Spacer()
                        .frame(height: 30) // Space before the buttons

                    // I Participate Button
                    Button(action: {
                        // Action to mark user attendance
                    }) {
                        Text("I'm Attending")
                            .foregroundColor(.white)
                            .fontWeight(.bold)
                            .padding()
                            .frame(maxWidth: .infinity) // Make button width to fill
                            .background(Color.green)
                            .cornerRadius(10)
                    }
                    .padding(.bottom, 20) // Space at the bottom
                }
                .padding(.horizontal) // Padding to the sides
            }
        }
        .navigationBarTitle("Event Details", displayMode: .inline)
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: date)
    }

    private func formattedTimeRange(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    private func formattedPrice(_ price: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter.string(from: NSNumber(value: price)) ?? "\(price)"
    }
}

struct EventDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleEvent = Event(id: UUID(), eventName: "Sample Event", eventDateTime: Date(), eventDescription: "This is a sample description.", location: "Sample Location", price: 19.99, gender: "All Welcome", minAge: 18, maxAge: 99, image: "https://yourimageurl.com/image.jpg")
        EventDetailView(event: sampleEvent)
    }
}

