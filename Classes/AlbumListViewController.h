//
//  AlbumListViewController.h
//  PhotoAlbums
//
//  Created by Gaurav on 20/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlbumListViewController : UITableViewController {
    NSManagedObjectContext *managedObjectContext;
    NSArray *albumTagData;
    UILabel *mHelpertextLabel;
}

@property (nonatomic, retain) NSArray *albumTagData;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

-(void)fetchAlbumsAndTagsFromCoredata;

@end
