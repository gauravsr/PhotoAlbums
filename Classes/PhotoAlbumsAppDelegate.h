//
//  PhotoAlbumsAppDelegate.h
//  PhotoAlbums
//
//  Created by raheja on 23/06/10.
//  Copyright Xebia IT Architects India Private Limited 2010. All rights reserved.
//

@interface PhotoAlbumsAppDelegate : NSObject <UIApplicationDelegate> 
{    
    NSManagedObjectModel			*managedObjectModel;
    NSManagedObjectContext			*managedObjectContext;	    
    NSPersistentStoreCoordinator	*persistentStoreCoordinator;

    UIWindow						*window;
    UINavigationController			*navigationController;	
}

@property (nonatomic, retain, readonly) NSManagedObjectModel			*managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext			*managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator	*persistentStoreCoordinator;

@property (nonatomic, retain) IBOutlet UIWindow							*window;
@property (nonatomic, retain) IBOutlet UINavigationController			*navigationController;

- (NSString *)applicationDocumentsDirectory;
- (NSString *)relativePhotoPathForAlbumId: (NSString *)albumId;
- (NSString *)relativeAudioPathForAlbumId: (NSString *)albumId;

@end

