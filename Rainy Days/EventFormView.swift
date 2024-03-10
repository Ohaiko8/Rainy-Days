import SwiftUI
import Cloudinary

struct EventFormView: View {
    @Binding var isPresented: Bool
    var onEventSave: ((Event) -> Void)?
    
    @State private var eventName = ""
    @State private var eventDateTime = Date()
    @State private var eventDescription = ""
    @State private var location = ""
    @State private var price = ""
    @State private var genderOptions = ["All Welcome", "Male", "Female"]
    @State private var selectedGender = "All Welcome"
    @State private var minAge = ""
    @State private var maxAge = ""
    @State private var selectedImage: UIImage?
    @State private var isImagePickerPresented = false
    @State private var imagePickerSourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var showSourceSelection = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Event Information")) {
                    TextField("Event Name", text: $eventName)
                    DatePicker("Date and Time", selection: $eventDateTime, displayedComponents: .date)
                    TextEditor(text: $eventDescription)
                    TextField("Location", text: $location)
                    TextField("Price", text: $price).keyboardType(.decimalPad)
                    Picker("Gender", selection: $selectedGender) {
                        ForEach(genderOptions, id: \.self) { option in
                            Text(option).tag(option)
                        }
                    }
                    TextField("Min Age", text: $minAge).keyboardType(.numberPad)
                    TextField("Max Age", text: $maxAge).keyboardType(.numberPad)
                    
                    Button("Select Image") {
                        showSourceSelection = true
                    }
                    
                    if let selectedImage = selectedImage {
                        Image(uiImage: selectedImage)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                    }
                }
                
                Section {
                    Button("Save") {
                        saveEvent()
                        
                    }
                }
            }
            .navigationBarTitle("New Event", displayMode: .inline)
            .navigationBarItems(trailing: Button("Cancel") { isPresented = false })
            .alert(isPresented: $showAlert) { Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK"))) }
            .actionSheet(isPresented: $showSourceSelection) {
                ActionSheet(title: Text("Select Image Source"), buttons: [
                    .default(Text("Camera")) {
                        imagePickerSourceType = .camera
                        isImagePickerPresented = true
                    },
                    .default(Text("Photo Library")) {
                        imagePickerSourceType = .photoLibrary
                        isImagePickerPresented = true
                    },
                    .cancel()
                ])
            }
            .sheet(isPresented: $isImagePickerPresented) {
                ImagePicker(isPresented: $isImagePickerPresented, selectedImage: $selectedImage, sourceType: imagePickerSourceType)
            }
            .onTapGesture {
                UIApplication.shared.endEditing()
            }
        }
    }
    
    private func saveEvent() {
        // Form validation
        guard !eventName.isEmpty,
              let priceDouble = Double(price),
              let minAgeInt = Int(minAge),
              let maxAgeInt = Int(maxAge),
              let image = selectedImage else {
            alertMessage = "Please fill in all fields correctly and select an image."
            showAlert = true
            return
        }

        // Image upload
        uploadImageToCloudinary(image: image) { imageUrl in
            guard let imageUrl = imageUrl else {
                DispatchQueue.main.async {
                    self.alertMessage = "Failed to upload image."
                    self.showAlert = true
                }
                return
            }

            // Event object creation
            let event = Event(
                id: UUID(), // Ensure an ID is assigned here if your Event struct expects an id
                eventName: self.eventName,
                eventDateTime: self.eventDateTime,
                eventDescription: self.eventDescription,
                location: self.location,
                price: priceDouble,
                gender: self.selectedGender,
                minAge: minAgeInt,
                maxAge: maxAgeInt,
                image: imageUrl // Assuming `imageName` field stores the URL or identifier of the image
            )

            // Save the event
            DispatchQueue.main.async {
                            if let onEventSave = self.onEventSave {
                                onEventSave(event)
                            } else {
                                // Fallback or default action if no onEventSave closure is provided
                                self.saveEventToLocalJson(event: event)
                            }
                            self.isPresented = false
                        }
        }
    }
    func saveEventToLocalJson(event: Event) {
        // Attempt to load existing events from local storage
        var events = self.loadEvents()
        
        // Append the new event to the array
        events.append(event)
        
        do {
            // Encode the updated events array to JSON data
            let data = try JSONEncoder().encode(events)
            
            // Construct the URL for the events.json file in the app's document directory
            if let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("events.json") {
                // Write the JSON data to the events.json file
                try data.write(to: url)
                print("Event saved successfully")
            }
        } catch {
            print("Failed to save event: \(error)")
            DispatchQueue.main.async {
                // Update alert message and show the alert to inform the user of the error
                self.alertMessage = "Failed to save event."
                self.showAlert = true
            }
        }
    }

    func loadEvents() -> [Event] {
        // Attempt to construct the URL for the events.json file
        if let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("events.json"),
           let data = try? Data(contentsOf: url) {
            // Decode the JSON data into an array of Event objects
            let decoder = JSONDecoder()
            if let loadedEvents = try? decoder.decode([Event].self, from: data) {
                return loadedEvents
            }
        }
        // Return an empty array if the file does not exist or the decoding fails
        return []
    }

}
    
    
    
func uploadImageToCloudinary(image: UIImage, completion: @escaping (String?) -> Void) {
    // Ensure the Cloudinary framework is imported and initialized
    let config = CLDConfiguration(cloudName: "dqvnjehbs", apiKey: "456752749853931", apiSecret: "sQbyYH_uqX_GzBML-Pp_Bk579Yc", secure: true)
    let cloudinary = CLDCloudinary(configuration: config)
    
    // Convert UIImage to Data
    guard let imageData = image.jpegData(compressionQuality: 0.5) else {
        print("Error converting image to Data")
        completion(nil)
        return
    }
    
    // Start the upload process
    cloudinary.createUploader().upload(data: imageData, uploadPreset: "cewde6jd") { uploadResult, error in
        if let error = error {
            // Handle error
            print("Error uploading image: \(error.localizedDescription)")
            completion(nil)
        } else if let uploadResult = uploadResult, let url = uploadResult.url {
            // Image was successfully uploaded
            print("Uploaded Image URL: \(url)")
            completion(url)
        } else {
            // Unknown error
            print("Unknown error occurred")
            completion(nil)
        }
    }
}
    
    func saveEvent(event: Event) {
        var events = loadEvents()
        events.append(event)
        
        do {
            let data = try JSONEncoder().encode(events)
            let url = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("events.json")
            try data.write(to: url)
        } catch {
            print(error)
        }
    }
    
    func loadEvents() -> [Event] {
        let url = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("events.json")
        if let url = url, let data = try? Data(contentsOf: url) {
            let decoder = JSONDecoder()
            if let loadedEvents = try? decoder.decode([Event].self, from: data) {
                return loadedEvents
            }
        }
        return []
    }

    extension UIApplication {
        func endEditing() {
            sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
