//
//  Page.h
//  PhotoAlbums
//
//  Created by Sourabh Raheja on 22/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Album;

@interface Page : NSManagedObject {
    NSString		*pageID;
	NSURL			*audioNoteURL;
}

@property (nonatomic, retain) NSString * audioNotePath;
@property (nonatomic, retain) NSString * textCaption;
@property (nonatomic, retain) NSDate * creationDate;
@property (nonatomic, retain) NSString * imageThumbnailPath;
@property (nonatomic, retain) NSNumber * pageOrder;
@property (nonatomic, retain) NSString * imagePath;
@property (nonatomic, retain) NSSet *album;

//transient properties
@property (nonatomic, retain) NSString		*pageID;
@property (nonatomic, retain) NSURL			*audioNoteURL;


- (BOOL) hasAudioNote;



@end

@interface Page (CoreDataGeneratedAccessors)

- (void)addAlbumObject:(Album *)value;
- (void)removeAlbumObject:(Album *)value;
- (void)addAlbum:(NSSet *)values;
- (void)removeAlbum:(NSSet *)values;
@end
