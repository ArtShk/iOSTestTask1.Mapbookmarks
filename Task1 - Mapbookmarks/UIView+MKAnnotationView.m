//
//  UIView+MKAnnotationView.m
//  Task1 - Mapbookmarks
//
//  Created by Art on 04.07.17.
//  Copyright © 2017 Art. All rights reserved.
//

#import "UIView+MKAnnotationView.h"
#import <MapKit/MKAnnotationView.h>

@implementation UIView (MKAnnotationView)

- (MKAnnotationView *) superAnnotationView {
    if ([self.superview isKindOfClass:[MKAnnotationView class]]) {
        return (MKAnnotationView *)self.superview;
    }
    if (!self.superview) {
        return nil;
    }
    return [self.superview superAnnotationView];
}

@end
