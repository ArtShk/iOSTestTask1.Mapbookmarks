//
//  TableViewController.h
//  Task1 - Mapbookmarks
//
//  Created by Art on 04.07.17.
//  Copyright © 2017 Art. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MapAnnotation.h"
#import "MapAnnotationGroup.h"
#import "ViewController.h"

@interface TableViewController : UITableViewController <UITableViewDataSource>

@property (strong, nonatomic) MapAnnotationGroup *bookmarksList;

- (IBAction)actionEdit:(UIBarButtonItem *)sender;

@end
