import SwiftUI

struct EventRow: View {
    var event: Event

    var body: some View {
        HStack {
            // Display only event name, image, and formatted date in the row
            Text(event.eventName)
            Spacer()
            Text("\(formattedDate(event.eventDateTime))")
            // You can add an ImageView here for the image if needed
        }
        .padding()
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct EventRow_Previews: PreviewProvider {
    static var previews: some View {
        let event = Event(
            eventName: "Sample Event",
            eventDateTime: Date(),
            eventDescription: "Sample description",
            location: "Sample location",
            price: 10.0,
            gender: "All Welcome",
            minAge: 18,
            maxAge: 30,
            image: "sample_image_url"
        )
        return EventRow(event: event)
    }
}


