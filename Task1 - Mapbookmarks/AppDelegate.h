//
//  AppDelegate.h
//  Task1 - Mapbookmarks
//
//  Created by Art on 04.07.17.
//  Copyright © 2017 Art. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

