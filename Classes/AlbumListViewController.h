//
//  AlbumListViewController.h
//  PhotoAlbums
//
//  Created by raheja on 23/06/10.
//  Copyright Xebia IT Architects India Private Limited 2010. All rights reserved.
//

@interface AlbumListViewController : UITableViewController <NSFetchedResultsControllerDelegate, UITableViewDelegate, UITableViewDataSource> 
{
	NSFetchedResultsController				*fetchedResultsController;
	NSManagedObjectContext					*managedObjectContext;

	NSMutableDictionary						*albumControllerDictionary;	
	UILabel									*mHelpertextLabel;
}

@property (nonatomic, retain) NSFetchedResultsController	*fetchedResultsController;
@property (nonatomic, retain) NSManagedObjectContext		*managedObjectContext;
@property (nonatomic, retain) NSMutableDictionary			*albumControllerDictionary;

@end
