//
//  Page.h
//  PhotoAlbums
//
//  Created by raheja on 29/06/10.
//  Copyright 2010 Xebia IT Architects India Private Limited. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Album;

@interface Page :  NSManagedObject  
{
	NSString		*pageID;
	NSURL			*audioNoteURL;
}

@property (nonatomic, retain) NSDate		* creationDate;
@property (nonatomic, retain) NSString		* audioNotePath;
@property (nonatomic, retain) NSNumber		* pageOrder;
@property (nonatomic, retain) NSString		* textCaption;
@property (nonatomic, retain) NSString		* imagePath;
@property (nonatomic, retain) NSString		* imageThumbnailPath;
@property (nonatomic, retain) Album			* album;

//transient properties
@property (nonatomic, retain) NSString		*pageID;
@property (nonatomic, retain) NSURL			*audioNoteURL;


- (BOOL) hasAudioNote;

@end



