//
//  AlbumListViewController.h
//  PhotoAlbums
//
//  Created by Gaurav on 20/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Album.h"

@interface AlbumListViewController : UITableViewController <NSFetchedResultsControllerDelegate> {
    NSFetchedResultsController *fetchedResultsController;
    NSManagedObjectContext *managedObjectContext;
    UILabel *mHelpertextLabel;
    Album                   *albumOfTypeTag;
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, assign) 	Album                   *albumOfTypeTag;


@end
