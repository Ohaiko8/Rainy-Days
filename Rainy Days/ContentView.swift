import SwiftUI
import MapKit

// MARK: - Location Manager
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var region: MKCoordinateRegion?
    @Published var weatherData: ForecastResponse?
    @Published var currentLocation: CLLocationCoordinate2D?
    private var initialLocationSet = false // Correctly added
    
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
            fetchWeatherData(for: location.coordinate) // Fetch weather on initial location update
        }
    }
    
    func centerOnUserLocation() {
        guard let location = locationManager.location else { return }
        let newRegion = MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
        self.region = newRegion
        fetchWeatherData(for: location.coordinate) // Fetch weather whenever re-centering
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
}

// MARK: - ContentView
import SwiftUI
import MapKit

import SwiftUI
import MapKit

struct ContentView: View {
    @ObservedObject var locationManager = LocationManager()
    @ObservedObject var weatherNotificationManager = WeatherNotificationManager()
    @State private var isMapFullScreen = false
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    MapView(region: $locationManager.region)
                        .edgesIgnoringSafeArea(.all)
                        .frame(height: isMapFullScreen ? UIScreen.main.bounds.height : UIScreen.main.bounds.height / 3.5)
                    
                    // This ensures the list is only visible when the map isn't in full-screen mode.
                    if !isMapFullScreen {
                        List(sampleEvents) { event in
                            EventRow(event: event)
                        }
                    }
                }
                
                // Floating buttons on the map
                VStack {
                    Spacer() // This pushes the button group down.
                    HStack {
                        Spacer() // Pushes the buttons to the right side of the view.
                        VStack(spacing: 16) {
                            Button(action: {
                                isMapFullScreen.toggle()
                            }) {
                                Image(systemName: isMapFullScreen ? "arrow.down.right.and.arrow.up.left" : "arrow.up.left.and.arrow.down.right")
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.black.opacity(0.75))
                                    .clipShape(Circle())
                            }
                            
                            Button(action: {
                                locationManager.centerOnUserLocation()
                            }) {
                                Image(systemName: "location.fill")
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.blue.opacity(0.75))
                                    .clipShape(Circle())
                            }
                            
                            Button(action: {
                                let message = locationManager.prepareWeatherSummary()
                                weatherNotificationManager.showWeatherNotification(with: message)
                            }) {
                                Image(systemName: "cloud.sun.fill")
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.orange.opacity(0.75))
                                    .clipShape(Circle())
                            }
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 500) // Adjust this padding to place the buttons correctly over the map.
                    }
                }
                
                // Weather notification view
                if weatherNotificationManager.showMessage {
                    VStack {
                        WeatherNotificationView(message: weatherNotificationManager.message)
                            .padding()
                            .animation(.easeInOut(duration: 0.5))
                            .transition(.move(edge: .top))
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                                    self.weatherNotificationManager.showMessage = false
                                }
                            }
                        Spacer()
                    }
                    .zIndex(1) // Ensure notification is always on top
                }
            }
            .navigationBarTitle("Events", displayMode: .inline)
        }
    }
}










struct WeatherNotificationView: View {
    var message: String
    
    var body: some View {
        Text(message)
            .padding()
            .frame(maxWidth: .infinity) // Ensures full width
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .shadow(radius: 5)
            .transition(.move(edge: .top).combined(with: .opacity))
            .animation(.easeInOut, value: message)
    }
}





// MARK: - App Entry Point
@main
struct RainyDaysApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

// MARK: - Preview Provider
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

extension LocationManager {
    func fetchWeatherData(for coordinate: CLLocationCoordinate2D) {
        let apiKey = "4cad6db54efef114fbd06ee53d7193b2"
        let urlString = "https://api.openweathermap.org/data/2.5/forecast?lat=\(coordinate.latitude)&lon=\(coordinate.longitude)&appid=\(apiKey)&units=metric"
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                DispatchQueue.main.async {
                    print("Error fetching weather data: \(error.localizedDescription)")
                }
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                DispatchQueue.main.async {
                    print("Received HTTP \(httpResponse.statusCode), expected 200 OK")
                    // Handle HTTP error
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    print("No data received")
                }
                return
            }
            
            // Print the raw JSON string for debugging
            if let jsonStr = String(data: data, encoding: .utf8) {
                print("Raw JSON string: \(jsonStr)")
            }
            
            do {
                let weatherResponse = try JSONDecoder().decode(ForecastResponse.self, from: data)
                DispatchQueue.main.async {
                    // Update your published property with the fetched data
                    self.weatherData = weatherResponse
                }
            } catch {
                DispatchQueue.main.async {
                    // Improved error logging for decoding errors
                    self.logDecodingError(error)
                }
            }
        }.resume()
    }
    
    private func logDecodingError(_ error: Error) {
        guard let decodingError = error as? DecodingError else {
            print("Failed to decode weather data: \(error.localizedDescription)")
            return
        }
        
        switch decodingError {
        case .dataCorrupted(let context):
            print("Data corrupted: \(context)")
        case .keyNotFound(let key, let context):
            print("Key '\(key)' not found, \(context.debugDescription), codingPath: \(context.codingPath)")
        case .typeMismatch(let type, let context):
            print("Type '\(type)' mismatch, \(context.debugDescription), codingPath: \(context.codingPath)")
        case .valueNotFound(let value, let context):
            print("Value '\(value)' not found, \(context.debugDescription), codingPath: \(context.codingPath)")
        @unknown default:
            print("Unknown decoding error: \(decodingError.localizedDescription)")
        }
    }
    
    func addRainOverlay(to mapView: MKMapView) {
        let overlay = MKTileOverlay(urlTemplate: "https://tile.openweathermap.org/map/precipitation_new/{z}/{x}/{y}.png?appid=your_api_key")
        overlay.canReplaceMapContent = false // Ensure map content isn't replaced by the overlay
        mapView.addOverlay(overlay, level: .aboveRoads)
    }
    
    func prepareWeatherSummary() -> String {
        guard let weatherData = weatherData, let firstForecast = weatherData.list.first else {
            return "Weather data is currently unavailable."
        }
        
        let temperature = Int(firstForecast.main.temp)
        let weatherCondition = firstForecast.weather.first?.main.lowercased() ?? "clear"
        let description = firstForecast.weather.first?.description ?? "clear skies"
        
        var advice = ""
        switch weatherCondition {
        case "rain":
            advice = "It's going to rain soon, don't forget your umbrella."
        case "clear":
            advice = "It's sunny outside, a perfect day for sunglasses!"
        case "clouds":
            advice = "It's cloudy, you might need a light jacket."
        default:
            advice = "It's \(description) outside."
        }
        
        return "Temperature: \(temperature)°C. \(advice)"
    }
    
}

struct ForecastResponse: Codable {
    let city: City
    let list: [ForecastPeriod]
    
    struct City: Codable {
        let name: String
        let country: String
    }
    
    struct ForecastPeriod: Codable {
        let dt: Int
        let main: Main
        let weather: [WeatherDetail]
        let dt_txt: String
        
        struct Main: Codable {
            let temp: Double
            let feels_like: Double
            let temp_min: Double
            let temp_max: Double
            let pressure: Int
            let humidity: Int
        }
        
        struct WeatherDetail: Codable {
            let id: Int
            let main: String
            let description: String
            let icon: String
        }
    }
}

struct MapView: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion?
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.showsUserLocation = true
        mapView.delegate = context.coordinator
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        if let region = region {
            uiView.setRegion(region, animated: true)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView
        
        init(_ parent: MapView) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
            // This method can be used to track user location updates
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            // This method can be customized to return different annotation views
            return nil
        }
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            // If you later decide to add overlays, such as polygons or polylines, handle their rendering here
            return MKOverlayRenderer(overlay: overlay)
        }
    }
}

class WeatherNotificationManager: ObservableObject {
    @Published var showMessage = false
    var message = ""
    
    func showWeatherNotification(with message: String) {
        self.message = message
        self.showMessage = true
        
        // Hide the message after 5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.showMessage = false
        }
    }
}
