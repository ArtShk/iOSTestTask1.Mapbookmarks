//
//  MapAnnotation.h
//  Task1 - Mapbookmarks
//
//  Created by Art on 04.07.17.
//  Copyright © 2017 Art. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MKAnnotation.h>

@interface MapAnnotation : NSObject <MKAnnotation>

@property (nonatomic, assign) CLLocationCoordinate2D  coordinate;
@property (nonatomic, copy) NSString                   *title;
@property (nonatomic, copy) NSString                   *subtitle;

@end

