//
//  Page.h
//  PhotoAlbums
//
//  Created by Gaurav on 20/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Album;

@interface Page : NSManagedObject

@property (nonatomic, retain) NSString * audioNotePath;
@property (nonatomic, retain) NSString * textCaption;
@property (nonatomic, retain) NSDate * creationDate;
@property (nonatomic, retain) NSString * imageThumbnailPath;
@property (nonatomic, retain) NSNumber * pageOrder;
@property (nonatomic, retain) NSString * imagePath;
@property (nonatomic, retain) Album *album;
@property (nonatomic) NSInteger pageID;
@property (nonatomic, retain) NSURL *audioNoteURL;

@end
