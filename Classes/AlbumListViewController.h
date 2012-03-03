//
//  AlbumListViewController.h
//  PhotoAlbums
//
//  Created by Gaurav on 20/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Album.h"
#import "OverlayViewController.h"

@class OverlayViewController;

@interface AlbumListViewController : UITableViewController <NSFetchedResultsControllerDelegate,
                                                            UISearchBarDelegate,
                                                            UITextFieldDelegate> 
{
    IBOutlet UISearchBar *searchBar;
    NSMutableArray *searchResults;
    BOOL searching;
    BOOL letUserSelectRow;
    OverlayViewController *ovController;
    NSFetchedResultsController *fetchedResultsController;
    NSManagedObjectContext *managedObjectContext;
    UILabel *mHelpertextLabel;
    Album *albumOfTypeTag;
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, assign) Album *albumOfTypeTag;

-(void)searchTableView;
-(void)doneSearching_Clicked:(id)sender;

@end
