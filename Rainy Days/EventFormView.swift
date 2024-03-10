import SwiftUI

struct EventFormView: View {
    @Binding var isPresented: Bool
    var onEventSave: (Event) -> Void

    @State private var eventName = ""
    @State private var eventDateTime = Date()
    @State private var eventDescription = ""
    @State private var location = ""
    @State private var price = ""
    @State private var genderOptions = ["All Welcome", "Male", "Female"]
    @State private var selectedGender = "All Welcome"
    @State private var minAge = ""
    @State private var maxAge = ""
    @State private var image = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Event Information")) {
                    TextField("Event Name", text: $eventName)
                    DatePicker("Date and Time", selection: $eventDateTime, in: Date()...)
                    TextEditor(text: $eventDescription) // Use $eventDescription here
                    TextField("Location", text: $location)
                    TextField("Price", text: $price)
                    Picker("Gender", selection: $selectedGender) {
                        ForEach(genderOptions, id: \.self) {
                            Text($0)
                        }
                    }
                    HStack {
                        TextField("Min Age", text: $minAge)
                            .keyboardType(.numberPad)
                        Text("to")
                        TextField("Max Age", text: $maxAge)
                            .keyboardType(.numberPad)
                    }
                    TextField("Image URL", text: $image)
                }

                Section {
                    Button("Save") {
                        // Validate and save event data
                        guard !eventName.isEmpty, !eventDescription.isEmpty, !location.isEmpty, !price.isEmpty, !minAge.isEmpty, !maxAge.isEmpty, !image.isEmpty else {
                            // Handle validation error
                            return
                        }

                        guard let priceDouble = Double(price), let minAgeInt = Int(minAge), let maxAgeInt = Int(maxAge) else {
                            // Handle conversion error
                            return
                        }

                        let newEvent = Event(
                            eventName: eventName,
                            eventDateTime: eventDateTime,
                            eventDescription: eventDescription,
                            location: location,
                            price: priceDouble,
                            gender: selectedGender,
                            minAge: minAgeInt,
                            maxAge: maxAgeInt,
                            image: image
                        )

                        onEventSave(newEvent)
                        isPresented = false
                    }
                }
            }
            .navigationBarTitle("New Event")
        }
    }
}

struct EventFormView_Previews: PreviewProvider {
    static var previews: some View {
        EventFormView(isPresented: .constant(true), onEventSave: { _ in })
    }
}
