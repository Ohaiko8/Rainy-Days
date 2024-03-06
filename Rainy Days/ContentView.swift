import SwiftUI
import MapKit

// MARK: - Event Model
struct Event: Identifiable {
    let id = UUID()
    let name: String
    let date: Date
    let dressCode: String
    let description: String
    let imageName: String
}

// MARK: - Sample Events
let sampleEvents = [
    Event(name: "Beach Party", date: Date(), dressCode: "Casual", description: "Enjoy a fun day at the beach.", imageName: "beach"),
    Event(name: "Formal Gala", date: Date().addingTimeInterval(86400), dressCode: "Black Tie", description: "A night of elegance.", imageName: "gala"),
]

// MARK: - EventRow View
struct EventRow: View {
    var event: Event
    
    var body: some View {
        HStack {
            Image(event.imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .clipShape(Circle())
            
            VStack(alignment: .leading) {
                Text(event.name).font(.headline)
                Text(event.date, style: .date)
                Text("Dress Code: \(event.dressCode)")
                Text(event.description).font(.subheadline).foregroundColor(.gray)
            }
        }
    }
}

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var region: MKCoordinateRegion?
    private var initialLocationSet = false // Flag to track initial centering

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        if !initialLocationSet {
            let newRegion = MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
            self.region = newRegion
            initialLocationSet = true // Prevent further automatic centering
        }
    }

    func centerOnUserLocation() {
        guard let location = locationManager.location else { return }
        let newRegion = MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
        self.region = newRegion
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
}



// MARK: - MapView
struct MapView: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion?

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.showsUserLocation = true
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        if let region = region {
            uiView.setRegion(region, animated: true)
        }
    }
}


// MARK: - ContentView
struct ContentView: View {
    @ObservedObject var locationManager = LocationManager()
    @State private var isMapFullScreen = false
    
    var body: some View {
        NavigationView {
            VStack {
                ZStack(alignment: Alignment(horizontal: .trailing, vertical: .top)) {
                    MapView(region: $locationManager.region)
                        .frame(height: isMapFullScreen ? UIScreen.main.bounds.height : UIScreen.main.bounds.height / 3)
                        .edgesIgnoringSafeArea(.all)
                    
                    VStack {
                        Button(action: {
                            isMapFullScreen.toggle()
                        }) {
                            Image(systemName: isMapFullScreen ? "arrow.down.right.and.arrow.up.left" : "arrow.up.left.and.arrow.down.right")
                                .padding()
                                .foregroundColor(.white)
                                .background(Color.black.opacity(0.75))
                                .clipShape(Circle())
                        }

                        Button(action: {
                            locationManager.centerOnUserLocation()
                        }) {
                            Image(systemName: "location.fill")
                                .padding()
                                .foregroundColor(.white)
                                .background(Color.blue.opacity(0.75))
                                .clipShape(Circle())
                        }
                    }
                    .padding(.trailing)
                    .padding(.top, isMapFullScreen ? 44 : 8)
                }
                
                if !isMapFullScreen {
                    List(sampleEvents) { event in
                        EventRow(event: event)
                    }
                }
            }
            .navigationBarTitle("Events", displayMode: .inline)
        }
    }
}


// MARK: - Preview Provider
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

@main
struct MapListApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

