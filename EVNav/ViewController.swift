//
//  ViewController.swift
//  EVNav
//
//  Created by Diego Martinez on 5/4/22.
//

import UIKit

import MapboxMaps
import MapboxCoreNavigation
import MapboxNavigation
import MapboxDirections

class ViewController: UIViewController, AnnotationInteractionDelegate {
    var navigationMapView: NavigationMapView!
    var routeOptions: NavigationRouteOptions?
    var routeResponse: RouteResponse?

    var beginAnnotation: PointAnnotation?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationMapView = NavigationMapView(frame: view.bounds)

        view.addSubview(navigationMapView)

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
        guard sender.state == .began else { return }

        // Converts point where user did a long press to map coordinates
        let point = sender.location(in: navigationMapView)

        let coordinate = navigationMapView.mapView.mapboxMap.coordinate(for: point)

        if let origin = navigationMapView.mapView.location.latestLocation?.coordinate {
            // Calculate the route from the user's location to the set destination
            calculateRoute(from: origin, to: coordinate)
        } else {
            print("Failed to get user location, make sure to allow location access for this application.")
        }
    }

    // Calculate route to be used for navigation
    func calculateRoute(from origin: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D) {
        // Coordinate accuracy is how close the route must come to the waypoint in order to be considered viable. It is measured in meters. A negative value indicates that the route is viable regardless of how far the route is from the waypoint.
        let origin = Waypoint(coordinate: origin, coordinateAccuracy: -1, name: "Start")
        let destination = Waypoint(coordinate: destination, coordinateAccuracy: -1, name: "Finish")
        print("Origin")
        print(origin)
        print("Destination")
        print(destination.coordinate.latitude)
        print(destination.coordinate.longitude)
        

        // Specify that the route is intended for automobiles avoiding traffic
        let routeOptions = NavigationRouteOptions(waypoints: [origin, destination], profileIdentifier: .automobileAvoidingTraffic)

        // Generate the route object and draw it on the map
        Directions.shared.calculate(routeOptions) { [weak self] (session, result) in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            case .success(let response):
                guard let route = response.routes?.first, let strongSelf = self else {
                    return
                }

                strongSelf.routeResponse = response
                strongSelf.routeOptions = routeOptions

                // Draw the route on the map after creating it
                strongSelf.drawRoute(route: route)

                if var annotation = strongSelf.navigationMapView.pointAnnotationManager?.annotations.first {
                    // Display callout view on destination annotation
                    annotation.textField = "Start navigation"
                    annotation.textColor = .init(UIColor.white)
                    annotation.textHaloColor = .init(UIColor.systemBlue)
                    annotation.textHaloWidth = 2
                    annotation.textAnchor = .top
                    annotation.textRadialOffset = 1.0
                    strongSelf.beginAnnotation = annotation
                   // strongSelf.navigationMapView.pointAnnotationManager?.syncAnnotations(annotation)
                }
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
}

