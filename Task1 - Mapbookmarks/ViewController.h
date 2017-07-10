//
//  ViewController.h
//  Task1 - Mapbookmarks
//
//  Created by Art on 04.07.17.
//  Copyright © 2017 Art. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <WYPopoverController.h>

@class MapAnnotationGroup;

@protocol ReloadDataDelegate

- (void)updateUserData: (NSArray *)arrayChangedParams;

@end


@interface ViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate, WYPopoverControllerDelegate>
{
     WYPopoverController *popoverController;
}


@property (weak, nonatomic) IBOutlet MKMapView     *mapView;
@property (strong, nonatomic) MapAnnotationGroup   *bookmarksList;
@property (strong, nonatomic) CLLocationManager    *locationManager;
@property (strong, nonatomic) CLLocation           *location;

@property (weak, nonatomic) id<ReloadDataDelegate> delegate;

@end

