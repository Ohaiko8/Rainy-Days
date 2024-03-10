import SwiftUI

struct EventRow: View {
    var event: Event
    
    var body: some View {
        HStack {
            // Use the detailed initializer of AsyncImage
            AsyncImage(url: URL(string: event.image)) { phase in
                // Handle the result based on the loading phase
                switch phase {
                case .empty:
                    // The image is loading. Show a progress indicator.
                    ProgressView()
                case .success(let image):
                    // The image successfully loaded. Display the image.
                    image.resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                case .failure:
                    // Image loading failed. Show a placeholder or error image.
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                        .foregroundColor(.gray)
                        .background(Color.white)
                        .clipShape(Circle())
                @unknown default:
                    // Future cases. Just in case.
                    EmptyView()
                }
            }
            .frame(width: 50, height: 50) // Set a frame for the AsyncImage
            
            VStack(alignment: .leading) {
                Text(event.eventName).font(.headline)
                Text(event.eventDescription).font(.subheadline).foregroundColor(.gray)
                // Display other event details as needed
            }
        }
    }
}
