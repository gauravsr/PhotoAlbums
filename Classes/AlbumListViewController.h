//
//  AlbumListViewController.h
//  PhotoAlbums
//
//  Created by Gaurav on 20/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Album.h"

@interface AlbumListViewController : UITableViewController <NSFetchedResultsControllerDelegate,
                                                            UISearchBarDelegate,
                                                            UITextFieldDelegate> {
    
    IBOutlet UISearchBar *searchBar;
    
    NSFetchedResultsController *fetchedResultsController;
    NSManagedObjectContext *managedObjectContext;
    UILabel *mHelpertextLabel;
    Album *albumOfTypeTag;
    NSMutableArray *searchResults;
    BOOL isSearching;
}

@property (nonatomic, assign) IBOutlet UISearchBar *searchBar;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, assign) Album *albumOfTypeTag;
@property (nonatomic, assign) NSMutableArray *searchResults;
@property (nonatomic, assign) BOOL isSearching;
@end
