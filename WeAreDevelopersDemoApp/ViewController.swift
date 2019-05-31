import UIKit
import TomTomOnlineSDKMaps
import TomTomOnlineSDKSearch
import TomTomOnlineSDKRouting

class ViewController: UIViewController, TTAnnotationDelegate, TTMapViewDelegate {
  
  @IBOutlet weak var tomtomMap: TTMapView!
  let tomtomSearchAPI = TTSearch()
  let tomtomRoutingAPI = TTRoute()
  
  var departureAnnotation: TTAnnotation?
  var destinationAnnotation: TTAnnotation?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.tomtomMap.annotationManager.delegate = self
    self.tomtomMap.delegate = self
    
    self.tomtomMap.onMapReadyCompletion {
      let searchQuery = TTSearchQueryBuilder
        .create(withTerm: "Gym 14055 Berlin Germany")
        .build()
      self.tomtomSearchAPI.search(with: searchQuery,
                                  completionHandle:
        { (response, error) in
          for result in response!.results {
            self.tomtomMap.annotationManager
              .add(TTAnnotation(coordinate: result.position))
          }
          self.tomtomMap.zoomToAllAnnotations()
      })
    }
  }
  
  func annotationManager(_ manager: TTAnnotationManager,
                         annotationClicked annotation: TTAnnotation) {
    if departureAnnotation == nil {
      departureAnnotation = annotation
    }
    else if destinationAnnotation == nil {
      destinationAnnotation = annotation
      let routeQuery = TTRouteQueryBuilder
        .create(withDest: departureAnnotation!.coordinate,
                andOrig: destinationAnnotation!.coordinate)
        .build()
      self.tomtomRoutingAPI.plan(with: routeQuery, completionHandler: {
        (result, error) in
        let mapRoute =
          TTMapRoute(coordinatesData: (result?.routes.first)!,
                     with: TTMapRouteStyle.defaultActive(),
                     imageStart: TTMapRoute.defaultImageDeparture(),
                     imageEnd: TTMapRoute.defaultImageDestination())
        
        self.tomtomMap.routeManager.add(mapRoute)
        self.tomtomMap.routeManager.bring(toFrontRoute: mapRoute)
        self.tomtomMap.routeManager.showAllRoutesOverview()
      })
    }
  }
  
  func mapView(_ mapView: TTMapView, didLongPress coordinate: CLLocationCoordinate2D) {
    departureAnnotation = nil
    destinationAnnotation = nil
    self.tomtomMap.routeManager.removeAllRoutes()
    self.tomtomMap.zoomToAllAnnotations()
  }
}
