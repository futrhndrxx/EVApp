//
//  ViewController.swift
//  EVNav
//
//  Created by Diego Martinez on 5/4/22.
//

import UIKit
import Foundation
import MapboxMaps
import MapboxCoreNavigation
import MapboxNavigation
import MapboxDirections
import Turf


class MapViewController: UIViewController, AnnotationInteractionDelegate, XMLParserDelegate {

    var navigationMapView: NavigationMapView!
    var routeOptions: NavigationRouteOptions?
    var routeResponse: RouteResponse?
    public var transportationMethod: String!
    var beginAnnotation: PointAnnotation?
    var globalOrigin: CLLocationCoordinate2D!
    var globalCoordinate: CLLocationCoordinate2D!
    var initializedRoute: Bool!
    var alertDescription: String = ""
    

   
    @IBOutlet weak var TransportationMode: UISegmentedControl!
    
    @IBAction func changeRoute(_ sender: UISegmentedControl) {
        if initializedRoute == true {
            switch sender.selectedSegmentIndex {
            case 0:
                transportationMethod = "Drive"
                calculateRoute(from: globalOrigin, to: globalCoordinate)
                print("Drive")
            case 1:
                transportationMethod = "Walk"
                calculateWalkingRoute(from: globalOrigin, to: globalCoordinate)
                print("Walk")
            case 2:
                transportationMethod = "Bike"
                calculateBikeRoute(from: globalOrigin, to: globalCoordinate)
                print("Bike")
            default:
                print("Error")
            }
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        transportationMethod = "Drive"
        initializedRoute = false
        struct Result: Codable {
            let success: Bool
            let result: StateCities
        }
    
        struct StateCities: Codable {
            let state: GasInfo
            let cities: [GasInfo]
        }
        struct GasInfo: Codable {
            let currency, name, lowerName, gasoline, midGrade, premium, diesel: String
        }
        
        let headers = [
          "content-type": "application/json",
          "authorization": "apikey 3jEWQAzO4FT3S7UtUUlb7E:6jW4MJXE5upn5UqJPa98vT"
        ]

        let request = NSMutableURLRequest(url: NSURL(string: "https://api.collectapi.com/gasPrice/stateUsaPrice?state=CA")! as URL,
                                                cachePolicy: .useProtocolCachePolicy,
                                            timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
       
/*
        
 
 
 
 
        let dataTask =  URLSession.shared.dataTask(with: request as URLRequest) {data, response, error in
            if let data = data {
                do {
                    let res = try JSONDecoder().decode(Result.self, from: data)
                    print(res)
                    print(res.result)
                    print(res.result.state.gasoline)
                    
                   

                } catch let error {
                    print(error)
                }
            }
        }
        dataTask.resume()
        */
        let gasPrice = 5.923
        
          /*if (error != nil) {
            print(error)
          } else {
              let httpResponse = response as? HTTPURLResponse
              print(httpResponse)
              print(httpResponse?.description)
              print(httpResponse?.statusCode)
              print(response?.description)
              print(data)
              let jsonResponse = String(data: data!, encoding: String.Encoding.utf8)
              print("JSON String: \(jsonResponse)")
              
              let data = Data(jsonResponse)
           
              
              //let json = try! JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? JSONObject
              
            //  let result = try? JSONDecoder().decode(Result.self, from: data!)
              
          }
        })
           */


     

        navigationMapView = NavigationMapView(frame: view.bounds)
        self.navigationItem.setHidesBackButton(true, animated: true)

        view.addSubview(navigationMapView)
        view.bringSubviewToFront(TransportationMode)

        // Set the annotation manager's delegate
        navigationMapView.mapView.mapboxMap.onNext(.mapLoaded) { [weak self] _ in
            guard let self = self else { return }
            self.navigationMapView.pointAnnotationManager?.delegate = self
        }

        
        
        
        // Configure how map displays the user's location
        navigationMapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        navigationMapView.userLocationStyle = .puck2D()
        
        
        
        let navigationViewportDataSource = NavigationViewportDataSource(navigationMapView.mapView, viewportDataSourceType: .raw)
        navigationViewportDataSource.followingMobileCamera.zoom = 15.0
        navigationMapView.navigationCamera.viewportDataSource = navigationViewportDataSource
        
        

        // Add a gesture recognizer to the map view
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(didLongPress(_:)))
        navigationMapView.addGestureRecognizer(longPress)
    }

    @objc func didLongPress(_ sender: UILongPressGestureRecognizer) {
        //presentBottomModal()
        initializedRoute = true
        guard sender.state == .began else { return }

        // Converts point where user did a long press to map coordinates
        let point = sender.location(in: navigationMapView)

        let coordinate = navigationMapView.mapView.mapboxMap.coordinate(for: point)
// new line
        globalCoordinate = coordinate
        if let origin = navigationMapView.mapView.location.latestLocation?.coordinate {
            globalOrigin = origin
            
            
            
            switch transportationMethod {
            case "Drive":
                print("Driving Route")
                getWeather()
                
            case "Walk":
                print("Walking Route")
            case "Bike":
                print("Biking Route")
                calculateBikeRoute(from:origin, to: coordinate)
            default:
                print("Error")
            }
            // Calculate the route from the user's location to the set destination
           // calculateRoute(from: origin, to: coordinate)
          //  calculateBikeRoute(from:origin, to: coordinate)
        } else {
            print("Failed to get user location, make sure to allow location access for this application.")
        }
    }
    
    func presentBottomModal() {
        let storyboard = UIStoryboard(name:"Sheet", bundle: nil)
        let sheetPresentationController = storyboard.instantiateViewController(withIdentifier: "SheetViewController") as! SheetViewController
        self.present(sheetPresentationController, animated: true, completion: nil)
    }
    

    func getWeather() {
        
        let origin = Waypoint(coordinate: globalOrigin, coordinateAccuracy: -1, name: "Start")
        // This is a pretty simple networking task, so the shared session will do.
        
        struct Data: Codable {
            let coord: Coord
            let weather: [Weather]
            let base: String
            let main: Main
            let visibility: Int
            let wind: Wind
            let clouds: Clouds
            let dt: Int
            let sys: Sys
            let timezone, id: Int
            let name: String
            let cod: Int
        }

        struct Clouds: Codable {
            let all: Int
        }

        struct Coord: Codable {
            let lon, lat: Double
        }

        struct Main: Codable {
            let temp, feels_like, temp_min, temp_max: Double
            let pressure, humidity: Int
        }

        struct Sys: Codable {
            let type, id: Int
            let country: String
            let sunrise, sunset: Int
        }

        struct Weather: Codable {
            let id: Int
            let main, description, icon: String
        }

        struct Wind: Codable {
            let speed: Double
            let deg: Int
        }
        
        let request = NSMutableURLRequest(url: NSURL(string: "https://api.openweathermap.org/data/2.5/weather?lat=\(origin.coordinate.latitude)&lon=\(origin.coordinate.longitude)&appid=ffb776a1302829c7944e16b33846f2d5")! as URL,
                                                cachePolicy: .useProtocolCachePolicy,
                                            timeoutInterval: 10.0)
        request.httpMethod = "GET"
        
 
 
 
        let dataTask =  URLSession.shared.dataTask(with: request as URLRequest) { [self]data, response, error in
            if let data = data {
                do {
                    let res = try JSONDecoder().decode(Data.self, from: data)
                    print(res.main.temp)
                    
                    let fahrenheit = round((res.main.temp - 273.15) * 9/5 + 32)
                    print(res.weather[0].description)
                    print(res.weather[0].icon)
                    self.alertDescription = "It is currently \(fahrenheit)°F with \(res.weather[0].description)"
                 
                    self.calculateRoute(from: self.globalOrigin, to: self.globalCoordinate)

                } catch let error {
                    print(error)
                }
            }
        }
        dataTask.resume()
        
        /*
        let headers = [
          "x-rapidapi-host": "community-open-weather-map.p.rapidapi.com",
          "x-rapidapi-key": "ffb776a1302829c7944e16b33846f2d5"
        ]
        
        
        let request = NSMutableURLRequest(url: NSURL(string: "https://api.openweathermap.org/data/2.5/weather?lat=\(origin.coordinate.latitude)&lon=\(origin.coordinate.longitude)&appid=ffb776a1302829c7944e16b33846f2d5")! as URL,
                                                cachePolicy: .useProtocolCachePolicy,
                                            timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
          if (error != nil) {
            print(error)
          } else {
                let httpResponse = response as? HTTPURLResponse
                print(httpResponse)
                print("DATA")
                let res = try JSONDecoder().decode(Current.self, from: data)
                print(res)
            
              
          }
        })
        dataTask.resume()
        */
        
                                        
    }
    
    // Calculate route to be used for navigation
    func calculateBikeRoute(from origin: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D) {
        // Coordinate accuracy is how close the route must come to the waypoint in order to be considered viable. It is measured in meters. A negative value indicates that the route is viable regardless of how far the route is from the waypoint.
        let origin = Waypoint(coordinate: origin, coordinateAccuracy: -1, name: "Start")
        let destination = Waypoint(coordinate: destination, coordinateAccuracy: -1, name: "Finish")
        print("Origin")
        print(origin.coordinate.latitude)
        print(origin.coordinate.longitude)
        
        
        
  
        
        
        print("Destination")
        print(destination.coordinate.latitude)
        print(destination.coordinate.longitude)
       
        
        
        // Specify that the route is intended for automobiles avoiding traffic
        let routeOptions = NavigationRouteOptions(waypoints: [origin, destination], profileIdentifier: .cycling)
        routeOptions.includesSteps = true
        routeOptions.includesAlternativeRoutes = true

        // Generate the route object and draw it on the map
        Directions.shared.calculate(routeOptions) { [weak self] (session, result) in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            case .success(let response):
                print("RESPONSE")
                print(response)
                guard let route = response.routes?.first, let strongSelf = self else {
                    return
                }

                
                strongSelf.routeResponse = response
                strongSelf.routeOptions = routeOptions
                
                
                
                
                let gasPrice = 5.923
                print(route.distance * 0.000621371 * gasPrice)
                // Draw the route on the map after creating it
                strongSelf.drawRoute(route: route)
                
                let miles : Double = route.distance * 0.000621371
                let distanceString = String(format: "%.2f", miles)
                let calories = 60 * miles
                let caloriesString = String(format: "%.2f", calories)
                
                if var annotation = strongSelf.navigationMapView.pointAnnotationManager?.annotations.first {
                    // Display callout view on destination annotation
                    annotation.textField = "Distance: \(distanceString) \n Calories Burned: \(caloriesString)"
                    annotation.textColor = .init(UIColor.white)
                    annotation.textHaloColor = .init(UIColor.systemBlue)
                    annotation.textHaloWidth = 2
                    annotation.textAnchor = .top
                    annotation.textRadialOffset = 1.0
                    strongSelf.beginAnnotation = annotation
                    strongSelf.navigationMapView.pointAnnotationManager?.annotations = [annotation]
                }
            }
        }
        
        
    }
    
    // Calculate route to be used for navigation
    func calculateWalkingRoute(from origin: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D) {
        // Coordinate accuracy is how close the route must come to the waypoint in order to be considered viable. It is measured in meters. A negative value indicates that the route is viable regardless of how far the route is from the waypoint.
        let origin = Waypoint(coordinate: origin, coordinateAccuracy: -1, name: "Start")
        let destination = Waypoint(coordinate: destination, coordinateAccuracy: -1, name: "Finish")
        print("Origin")
        print(origin.coordinate.latitude)
        print(origin.coordinate.longitude)
        print("Destination")
        print(destination.coordinate.latitude)
        print(destination.coordinate.longitude)
       
        
        
        // Specify that the route is intended for automobiles avoiding traffic
        let routeOptions = NavigationRouteOptions(waypoints: [origin, destination], profileIdentifier: .walking)
        routeOptions.includesSteps = true
        routeOptions.includesAlternativeRoutes = true

        // Generate the route object and draw it on the map
        Directions.shared.calculate(routeOptions) { [weak self] (session, result) in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            case .success(let response):
                print("RESPONSE")
                print(response)
                guard let route = response.routes?.first, let strongSelf = self else {
                    return
                }

                
                strongSelf.routeResponse = response
                strongSelf.routeOptions = routeOptions
                print("DISTANCE IN Miles")
                print(route.distance * 0.000621371) // convert meters to miles
                print("Cost of Drive")
                let gasPrice = 5.923
                print(route.distance * 0.000621371 * gasPrice)
                // Draw the route on the map after creating it
                strongSelf.drawRoute(route: route)
                // average calories burned a mile for an average male while walking
                let miles : Double = route.distance * 0.000621371
                let distanceString = String(format: "%.2f", miles)
                let calories = 96 * miles
                let caloriesString = String(format: "%.2f", calories)
                if var annotation = strongSelf.navigationMapView.pointAnnotationManager?.annotations.first {
                    // Display callout view on destination annotation
                    annotation.textField = "Distance: \(distanceString) \n Calories Burned: \(caloriesString)"
                    annotation.textColor = .init(UIColor.white)
                    annotation.textHaloColor = .init(UIColor.systemBlue)
                    annotation.textHaloWidth = 2
                    annotation.textAnchor = .top
                    annotation.textRadialOffset = 1.0
                    strongSelf.beginAnnotation = annotation
                    strongSelf.navigationMapView.pointAnnotationManager?.annotations = [annotation]
                }
            }
        }
        
        
    }
    
    // Calculate route to be used for navigation
    func calculateRoute(from origin: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D) {
        // Coordinate accuracy is how close the route must come to the waypoint in order to be considered viable. It is measured in meters. A negative value indicates that the route is viable regardless of how far the route is from the waypoint.
        let origin = Waypoint(coordinate: origin, coordinateAccuracy: -1, name: "Start")
        let destination = Waypoint(coordinate: destination, coordinateAccuracy: -1, name: "Finish")
        print("Origin")
        print(origin.coordinate.latitude)
        print(origin.coordinate.longitude)
        print("Destination")
        print(destination.coordinate.latitude)
        print(destination.coordinate.longitude)
       
        
        
        // Specify that the route is intended for automobiles avoiding traffic
        let routeOptions = NavigationRouteOptions(waypoints: [origin, destination], profileIdentifier: .automobileAvoidingTraffic)
        routeOptions.includesSteps = true
        routeOptions.includesAlternativeRoutes = true

        // Generate the route object and draw it on the map
        Directions.shared.calculate(routeOptions) { [weak self] (session, result) in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            case .success(let response):
                print("RESPONSE")
                print(response)
                guard let route = response.routes?.first, let strongSelf = self else {
                    return
                }

                
                strongSelf.routeResponse = response
                strongSelf.routeOptions = routeOptions
                let distanceMiles = round(route.distance * 0.000621371 * 100) / 100.0
                if distanceMiles < 2 {
                    
                    let alert = UIAlertController(title: "Your destination is only \(distanceMiles) miles away." , message:  "\(self!.alertDescription), today is a great day for a bike or walk!", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Bike", style: .default, handler: { action in
                        switch action.style{
                            case .default:
                                self?.transportationMethod = "Bike"
                            self?.calculateBikeRoute(from: self!.globalOrigin, to: self!.globalCoordinate)
                                self?.TransportationMode.selectedSegmentIndex = 2
                            
                            case .cancel:
                            print("cancel")
                            
                            case .destructive:
                            print("destructive")
                            
                        }
                    }))
                    alert.addAction(UIAlertAction(title: "Walk", style: .default, handler: { action in
                        switch action.style{
                            case .default:
                            self?.transportationMethod = "Walk"
                            self?.calculateWalkingRoute(from: self!.globalOrigin, to: self!.globalCoordinate)
                            self?.TransportationMode.selectedSegmentIndex = 1
                            
                            case .cancel:
                            print("cancel")
                            
                            case .destructive:
                            print("destructive")
                            
                        }
                    }))
                    
                    alert.addAction(UIAlertAction(title: "Maybe next Time!", style: .default, handler: { action in
                        switch action.style{
                            case .default:
                            print("default")
                            
                            case .cancel:
                            print("cancel")
                            
                            case .destructive:
                            print("destructive")
                            
                        }
                    }))
                    self!.present(alert, animated: true, completion: nil)
//                    self?.customAlert!.showAlert(with: "Today is a great day for a bike or walk!", message: "Your destination is only \(distanceMiles) miles away.", on: self!)
                    
                }
                
                let gasPrice = 5.923
                let miles : Double = route.distance * 0.000621371
                
                if CarInfoViewController.fuelType == "gasoline"
                {
                    print("GASOLINE")
                    // 6760 / mpg  -> g / km * 1.609 -> g / m
                  //  let carbonEmissions: Double = round((6760 / CarInfoViewController.milesPerGallon) * 1.609 * miles * 0.00220462)
                    let carbonEmissions: Double = (miles / CarInfoViewController.milesPerGallon) * 19.6
                    
                    let carbonString: String = String(format: "%.2f", carbonEmissions)
                    // total miles / mpg * gas price
                    print(gasPrice)
                    let costOfDrive: Double = (miles / CarInfoViewController.milesPerGallon) * gasPrice
                    print(costOfDrive)
                    let costString: String = String(format: "%.2f", costOfDrive)
                    
                    // Draw the route on the map after creating it
                    strongSelf.drawRoute(route: route)
                    if var annotation = strongSelf.navigationMapView.pointAnnotationManager?.annotations.first {
                        // Display callout view on destination annotation
                        annotation.textField = "Cost of Drive: $\(costString) \n Carbon Emitted: \(carbonString) lbs"
                        annotation.textColor = .init(UIColor.white)
                        annotation.textHaloColor = .init(UIColor.systemBlue)
                        annotation.textHaloWidth = 2
                        annotation.textAnchor = .top
                        annotation.textRadialOffset = 1.0
                        strongSelf.beginAnnotation = annotation
                        strongSelf.navigationMapView.pointAnnotationManager?.annotations = [annotation]
                    }
                }
                else {
                    print("ELECTRIC")
                    // Gasoline releases 19.6 pounds of CO2 per gallon when burned
                    //https://css.umich.edu/publications/factsheets/sustainability-indicators/carbon-footprint-factsheet
                    let carbonEmissions: Double = (miles / CarInfoViewController.avgGasMPG) * 19.6
                    let carbonString: String = String(format: "%.2f", carbonEmissions)

                    //let carbonEmissions: Double = round((6760 / CarInfoViewController.avgGasMPG) * 1.609 * miles * 0.00220462)
                    
                    // cost estimate
                    let costOfDrive: Double = 0.05 * miles
                    let costString: String = String(format: "%.2f", costOfDrive)

                    print(miles)
                    // Draw the route on the map after creating it
                    strongSelf.drawRoute(route: route)
                    if var annotation = strongSelf.navigationMapView.pointAnnotationManager?.annotations.first {
                        // Display callout view on destination annotation
                        annotation.textField = "Cost of Drive $\(costString) \nCarbon Emissions Saved: \(carbonString) lbs"
                        annotation.textColor = .init(UIColor.white)
                        annotation.textHaloColor = .init(UIColor.systemBlue)
                        annotation.textHaloWidth = 2
                        annotation.textAnchor = .top
                        annotation.textRadialOffset = 1.0
                        strongSelf.beginAnnotation = annotation
                        strongSelf.navigationMapView.pointAnnotationManager?.annotations = [annotation]
                    }
                }
                
                // total miles / mpg * gas price
                
                // Draw the route on the map after creating it
              //  strongSelf.drawRoute(route: route)
                
                
                
            }
        }
        
        
    }
    
    

    func drawRoute(route: Route) {

        navigationMapView.show([route])
        navigationMapView.showRouteDurations(along: [route])
        
        // Show destination waypoint on the map
        navigationMapView.showWaypoints(on: route)
        
    }
    
    private func createSampleView(withText text: String) -> UIView {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 14)
        label.numberOfLines = 0
        label.textColor = .black
        label.backgroundColor = .white
        label.textAlignment = .center
        return label
    }

    // Present the navigation view controller when the annotation is selected
    func annotationManager(_ manager: AnnotationManager, didDetectTappedAnnotations annotations: [Annotation]) {
        guard annotations.first?.id == beginAnnotation?.id,
            let routeResponse = routeResponse, let routeOptions = routeOptions else {
            return
        }
        
        let navigationViewController = NavigationViewController(for: routeResponse, routeIndex: 0, routeOptions: routeOptions)
        navigationViewController.modalPresentationStyle = .fullScreen
        self.present(navigationViewController, animated: true, completion: nil)
    }
    
    private func addViewAnnotation(at coordinate: CLLocationCoordinate2D) {
        let options = ViewAnnotationOptions(
            geometry: Point(coordinate),
            width: 100,
            height: 40,
            allowOverlap: false,
            anchor: .center
        )
        let sampleView = createSampleView(withText: "Hello world!")
        try? navigationMapView.mapView.viewAnnotations.add(sampleView, options: options)
    }
    
//    @objc public func dismissAlert() {
//        print("DISMISS")
//
//        customAlert!.dismissAlert()
//    }
//
//    @objc public func walkRoute() {
//        print("WALK")
//        transportationMethod = "Walk"
//        calculateWalkingRoute(from: globalOrigin, to: globalCoordinate)
//        TransportationMode.selectedSegmentIndex = 1
//        customAlert!.walkRoute()
//    }
//
//    @objc public func changeTobikeRoute() {
//        print("BIKE")
//        print("UYEWORIJEOIFJOEIW")
//        self.transportationMethod = "Bike"
//        self.calculateBikeRoute(from: globalOrigin, to: globalCoordinate)
//        TransportationMode.selectedSegmentIndex = 2
//        customAlert!.bikeRoute()
//    }
}

//class MyAlert: MapViewController {
//
//        struct Constants {
//            static let backgroundAlphaTo: CGFloat = 0.6
//        }
//
//        private let backgroundView: UIView = {
//            let backgroundView = UIView()
//            backgroundView.backgroundColor = .black
//            backgroundView.alpha = 0
//            return backgroundView
//        }()
//
//        private let alertView: UIView = {
//            let alert = UIView()
//            alert.backgroundColor = .white
//            alert.layer.masksToBounds = true
//            alert.layer.cornerRadius = 12
//            return alert
//        }()
//        private var myTargetView: UIView?
//
//        func showAlert(with title: String, message: String, on viewController: UIViewController) {
//            guard let targetView = viewController.view else {
//                return
//            }
//
//            myTargetView = targetView
//            backgroundView.frame = targetView.bounds
//            targetView.addSubview(backgroundView)
//            targetView.addSubview(alertView)
//
//            alertView.frame = CGRect(x: 40, y: -300, width: targetView.frame.self.width-80, height: 300)
//
//            let titleLabel = UILabel(frame: CGRect(x: 0 , y: 0, width: alertView.frame.size.width, height: 80))
//            titleLabel.text = title
//            titleLabel.textAlignment = .center
//            alertView.addSubview(titleLabel)
//
//            let messageLabel = UILabel(frame: CGRect(x: 0 , y: 80, width: alertView.frame.size.width, height: 170))
//            messageLabel.text = ""
//
//            messageLabel.text = message
//            messageLabel.textAlignment = .left
//            messageLabel.numberOfLines = 0
//            alertView.addSubview(messageLabel)
//
//
//
//
//            let dismissButton = UIButton(frame: CGRect(x: 0, y: alertView.frame.size.height-50, width: alertView.frame.size.width, height: 50))
//            dismissButton.setTitle("Maybe next time!", for: .normal)
//            dismissButton.setTitleColor(.link, for: .normal)
//            dismissButton.addTarget(self, action: #selector(closeAlert), for: .touchUpInside)
//            alertView.addSubview(dismissButton)
//
//            let walkButton = UIButton(frame: CGRect(x: 0, y: alertView.frame.size.height-130, width: alertView.frame.size.width, height: 50))
//            walkButton.setTitle("Walk", for: .normal)
//            walkButton.setTitleColor(.link, for: .normal)
//            walkButton.addTarget(self, action: #selector(walkingRoute), for: .touchUpInside)
//            alertView.addSubview(walkButton)
//
//            let bikeButton = UIButton(frame: CGRect(x: 0, y: alertView.frame.size.height-90, width: alertView.frame.size.width, height: 50))
//            bikeButton.setTitle("Bike", for: .normal)
//            bikeButton.setTitleColor(.link, for: .normal)
//            bikeButton.addTarget(self, action: #selector(bikeRoute), for: .touchUpInside)
//            alertView.addSubview(bikeButton)
//
//            UIView.animate(withDuration: 0.25,
//                           animations: {
//                            self.backgroundView.alpha = Constants.backgroundAlphaTo
//            }, completion: {done in
//                if done{
//                UIView.animate(withDuration: 0.25, animations: {
//                    self.alertView.center = targetView.center
//                })
//            }})
//
//        }
//
//        @objc func walkingRoute() {
//            print("WALK ROUTE")
//            guard let targetView = myTargetView else {
//                return
//            }
//            UIView.animate(withDuration: 0.25,
//                           animations: {
//                self.alertView.frame = CGRect(x: 40, y: targetView.frame.size.height, width: targetView.frame.self.width-80, height: 300)
//            }, completion: {done in
//                if done{
//                UIView.animate(withDuration: 0.25, animations: {
//                    self.backgroundView.alpha = 0
//                }, completion: {done in
//                    if done {
//                        self.alertView.removeFromSuperview()
//                        self.backgroundView.removeFromSuperview()
//                    }
//                })
//            }})
//            self.changeTobikeRoute()
//
//
//
//        }
//
//        @objc func bikeRoute() {
//
//            guard let targetView = myTargetView else {
//                return
//            }
//            UIView.animate(withDuration: 0.25,
//                           animations: {
//                self.alertView.frame = CGRect(x: 40, y: targetView.frame.size.height, width: targetView.frame.self.width-80, height: 300)
//            }, completion: {done in
//                if done{
//                UIView.animate(withDuration: 0.25, animations: {
//                    self.backgroundView.alpha = 0
//                }, completion: {done in
//                    if done {
//                        self.alertView.removeFromSuperview()
//                        self.backgroundView.removeFromSuperview()
//                    }
//                })
//            }})
//            self.changeTobikeRoute()
//
//
//        }
//
//    @objc func closeAlert() {
//
//        guard let targetView = myTargetView else {
//            return
//        }
//        UIView.animate(withDuration: 0.25,
//                       animations: {
//            self.alertView.frame = CGRect(x: 40, y: targetView.frame.size.height, width: targetView.frame.self.width-80, height: 300)
//        }, completion: {done in
//            if done{
//            UIView.animate(withDuration: 0.25, animations: {
//                self.backgroundView.alpha = 0
//            }, completion: {done in
//                if done {
//                    self.alertView.removeFromSuperview()
//                    self.backgroundView.removeFromSuperview()
//
//                }
//            })
//        }})
//
//
//
//    }
//}



  






