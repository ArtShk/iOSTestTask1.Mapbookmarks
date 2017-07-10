//
//  TableViewController.m
//  Task1 - Mapbookmarks
//
//  Created by Art on 04.07.17.
//  Copyright © 2017 Art. All rights reserved.
//

#import "TableViewController.h"

@interface TableViewController()

@property (strong, nonatomic) NSMutableArray *bookmarksArray;

@end

@implementation TableViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    if (!self.bookmarksList) {
        self.bookmarksList.bookmarks = [NSArray array];
        self.bookmarksList.name = @"Bookmarks";
    }
}

#pragma mark - Actions

- (IBAction)actionEdit:(UIBarButtonItem *)sender {
    if (self.editing) {
        sender.title = @"Edit";
        [super setEditing:NO];
    } else {
        sender.title = @"Done";
        [super setEditing:YES];
    }
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.bookmarksList.bookmarks count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    MapAnnotation *mapAnnotation = [self.bookmarksList.bookmarks objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@:(%1.2f,%1.2f)",mapAnnotation.title, mapAnnotation.coordinate.latitude, mapAnnotation.coordinate.longitude];
    return cell;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        MapAnnotation *annotation = [self.bookmarksList.bookmarks objectAtIndex:indexPath.row];
        self.bookmarksArray = [NSMutableArray arrayWithArray:self.bookmarksList.bookmarks];
        
        [self.bookmarksArray  removeObject:annotation];
        self.bookmarksList.bookmarks = self.bookmarksArray;
        [tableView beginUpdates];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        [tableView endUpdates];
        
    }
}

@end
