import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate {

    var map: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()
        map = MKMapView(frame: view.bounds)
        view.addSubview(map)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let geojson = NSJSONSerialization.JSONObjectWithData(
            NSData(contentsOfFile:
                NSBundle.mainBundle().pathForResource("features", ofType: "json")!)!,
            options: nil,
            error: nil) as! NSDictionary
        var annotations = NSMutableArray()
        for feature: NSDictionary in geojson["features"] as! Array {
            if let geometry = feature["geometry"] as? NSDictionary,
                coordinates = geometry["coordinates"] as? NSArray,
                properties = feature["properties"] as? NSDictionary,
                title = properties["title"] as? String {
                annotations.addObject({
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = CLLocationCoordinate2D(latitude: coordinates[1] as! Double,
                        longitude: coordinates[0] as! Double)
                    annotation.title = title
                    return annotation
                    }())
            }
        }
        map.addAnnotations(annotations as [AnyObject])
        map.showAnnotations(map.annotations, animated: false)
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(2 * NSEC_PER_SEC)), dispatch_get_main_queue()) { [unowned self] in
            self.map.selectAnnotation(annotations[0] as! MKAnnotation, animated: true)
            println("single selection: \(self.map.selectedAnnotations)")
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(4 * NSEC_PER_SEC)), dispatch_get_main_queue()) { [unowned self] in
            self.map.selectedAnnotations = annotations.subarrayWithRange(NSRange(location: 1, length: 2)) as! [MKAnnotation]
            println("multiple selection: \(self.map.selectedAnnotations)")
        }
    }

}
