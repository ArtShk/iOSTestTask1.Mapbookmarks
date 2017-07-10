//
//  ViewController.m
//  Task1 - Mapbookmarks
//
//  Created by Art on 04.07.17.
//  Copyright © 2017 Art. All rights reserved.
//

#import "ViewController.h"
#import "MapAnnotation.h"
#import "MapAnnotationGroup.h"
#import "UIView+MKAnnotationView.h"
#import "TableViewController.h"



@interface ViewController ()

@property (strong, nonatomic) NSMutableArray *bookmarksArray;
@property (strong, nonatomic) CLGeocoder     *geoCoder;
@property (strong, nonatomic) MKDirections   *direction;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.locationManager = [[CLLocationManager alloc ] init];
    self.geoCoder = [[CLGeocoder alloc] init];
    self.locationManager.delegate = self;
    [self.locationManager requestAlwaysAuthorization];
    [self.locationManager startUpdatingLocation];
    self.mapView.showsUserLocation = YES;
    
    if (!self.bookmarksArray) {
        self.bookmarksArray = [NSMutableArray array];
    }
    
    if (!self.bookmarksList) {
        self.bookmarksList = [[MapAnnotationGroup alloc] init];
        self.bookmarksList.name = @"Bookmarks";
    }
    
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(actionLongPress:)];
    
    [self.view addGestureRecognizer:longPressGesture];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    if ([self.geoCoder isGeocoding]) {
        [self.geoCoder cancelGeocode];
    }
    if ([self.direction isCalculating]) {
        [self.direction cancel];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [self reloadMapAnnotations];
}

- (void)showAlertWithTitle:(NSString *)title andMessage:(NSString *)message {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"ok"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * _Nonnull action) {
                                                              [alertController dismissViewControllerAnimated:YES completion:nil];
                                                          }];
    [alertController addAction:defaultAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)reloadMapAnnotations {
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView addAnnotations:self.bookmarksList.bookmarks];
    self.bookmarksList  = nil;
    self.bookmarksArray = [NSMutableArray arrayWithArray:self.bookmarksList.bookmarks];

}

#pragma mark - Actions

- (void)actionLongPress:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded) {
        CGPoint pointOnMainView   = [sender locationInView:self.view];
        MapAnnotation *annotation = [[MapAnnotation alloc] init];
        
        annotation.title        = @"Unnamed bookmarks";
        annotation.subtitle     = @"Unnamed bookmarks";
        annotation.coordinate   = [self.mapView convertPoint:pointOnMainView toCoordinateFromView:self.view];
        
        [self.mapView addAnnotation:annotation];
        [self.bookmarksArray addObject:annotation];
        NSLog(@"%@",self.bookmarksArray);
    }
}

- (IBAction)actionShowAll:(UIBarButtonItem *)sender {
    MKMapRect zoomRect = MKMapRectNull;
    for (id <MKAnnotation> annotation in self.mapView.annotations) {
        CLLocationCoordinate2D location = annotation.coordinate;
        MKMapPoint center = MKMapPointForCoordinate(location);
        static double delta = 20000;
        MKMapRect rect = MKMapRectMake(center.x - delta, center.y - delta, delta * 2, delta * 2);
        zoomRect = MKMapRectUnion(zoomRect, rect);
    }
    zoomRect = [self.mapView mapRectThatFits:zoomRect];
    
    [self.mapView setVisibleMapRect:zoomRect
                        edgePadding:UIEdgeInsetsMake(70, 50, 50, 50)
                           animated:YES];
}

- (IBAction)actionShowBookmarks:(UIBarButtonItem *)sender {
    TableViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"TableViewController"];
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
    
    nc.modalPresentationStyle = UIModalPresentationPopover;
    nc.popoverPresentationController.barButtonItem = sender;
    [self presentViewController:nc animated:YES completion:nil];
    
}


- (void)actionDescription:(UIButton *)sender {
    MKAnnotationView *annotationView = [sender superAnnotationView];
    
    if (!annotationView) {
        return;
    }
    
    CLLocationCoordinate2D coordinate = annotationView.annotation.coordinate;
    CLLocation *location = [[CLLocation alloc] initWithLatitude:coordinate.latitude
                                                      longitude:coordinate.longitude];
    [self.geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        NSString *message = nil;
        if (error) {
            message = [error localizedDescription];
        } else  {
            if ([placemarks count] > 0 ) {
                MKPlacemark *placeMark = [placemarks firstObject];
                message = [placeMark.addressDictionary description];
            } else {
                message = @"No Placemarks Found";
            }
        }
        [self showAlertWithTitle:@"Location" andMessage:message];
    }];
}

- (void)actionDirection:(UIButton *)sender {
    MKAnnotationView *annotationView = [sender superAnnotationView];
    
    if (!annotationView) {
        return;
    }
    
    if ([self.direction isCalculating]) {
        [self.direction cancel];
    }
    
    CLLocationCoordinate2D coordinate = annotationView.annotation.coordinate;
    
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
    request.source = [MKMapItem mapItemForCurrentLocation];
    
    MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:coordinate];
    MKMapItem *destination = [[MKMapItem alloc] initWithPlacemark:placemark];
    request.destination = destination;
    request.transportType = MKDirectionsTransportTypeAutomobile;
    request.requestsAlternateRoutes = YES;
    
    self.direction = [[MKDirections alloc] initWithRequest:request];
    [self.direction calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            [self showAlertWithTitle:@"Error" andMessage:[error localizedDescription]];
        } else if ([response.routes count] == 0) {
            [self showAlertWithTitle:@"Error" andMessage:@"No Routers Found"];
        } else {
            [self.mapView removeOverlays:[self.mapView overlays]];
            
            NSMutableArray *arrayOverlays = [NSMutableArray array];
            
            for (MKRoute *route in response.routes) {
                [arrayOverlays addObject:route.polyline];
            }
//            for (id<MKAnnotation> annotation in self.mapView.annotations) {
//                if (![annotationView.annotation isEqual: annotation]) {
//                    [self.mapView removeAnnotation:annotation];
//                }
//            }
            [self.mapView addOverlays:arrayOverlays level:MKOverlayLevelAboveRoads];
        }
    }];
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSLog(@"Segue = %@",segue.identifier);
    if ([segue.identifier isEqualToString:@"ShowBookmarks"]) {
        TableViewController *vc = (TableViewController*)segue.destinationViewController;
        self.bookmarksList.bookmarks = self.bookmarksArray;
        vc.bookmarksList = self.bookmarksList;
        NSLog(@"%@",vc.bookmarksList);
    }
}

#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
    
    static NSString *identifiere = @"Annotation";
    
    MKPinAnnotationView *pin = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:identifiere];
    
    if (!pin) {
        pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifiere];
        
        pin.pinTintColor    = [MKPinAnnotationView purplePinColor];
        pin.animatesDrop    = YES;
        pin.canShowCallout  = YES;
//        pin.draggable       = YES;
        
        UIButton *descriptionButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        [descriptionButton addTarget:self action:@selector(actionDescription:) forControlEvents:UIControlEventTouchUpInside];
        pin.rightCalloutAccessoryView = descriptionButton;
        
        UIButton *directionButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
        [directionButton addTarget:self action:@selector(actionDirection:) forControlEvents:UIControlEventTouchUpInside];
        pin.leftCalloutAccessoryView = directionButton;
        
    } else {
        pin.annotation = annotation;
    }
    return pin;
}

//При изменении местоположения метки
//- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState {
//    if (newState == MKAnnotationViewDragStateEnding) {
//        CLLocationCoordinate2D location = view.annotation.coordinate;
//        MKMapPoint point = MKMapPointForCoordinate(location);
//    }
//}


#pragma mark -  WYPopoverControllerDelegate

- (BOOL)popoverControllerShouldDismissPopover:(WYPopoverController *)controller {
    return YES;
}

- (void)popoverControllerDidDismissPopover:(WYPopoverController *)controller {
    popoverController.delegate = nil;
    popoverController = nil;
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    [self.locationManager requestAlwaysAuthorization];
    [self.locationManager startUpdatingLocation];
    [self setLocation: locations.lastObject];
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id <MKOverlay>)overlay {
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
        renderer.lineWidth = 2.f;
        renderer.strokeColor = [UIColor colorWithRed:0.f green:0.5f blue:0.7f alpha:0.8f];
        return renderer;
    }
    return nil;
}

@end
