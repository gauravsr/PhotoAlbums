//
//  Album.h
//  PhotoAlbums
//
//  Created by raheja on 29/06/10.
//  Copyright 2010 Xebia IT Architects India Private Limited. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Page;

@interface Album :  NSManagedObject  
{
	NSString *albumID;
}

@property (nonatomic, retain) NSString		*coverImagePath;
@property (nonatomic, retain) NSString		*albumPath;
@property (nonatomic, retain) NSString		*title;
@property (nonatomic, retain) NSNumber		*albumOrder;
@property (nonatomic, retain) NSDate		*creationDate;
@property (nonatomic, retain) NSSet			*pages;
@property (nonatomic, assign) BOOL           hidden;

//transient properties
@property (nonatomic, retain) NSString		*albumID;

@end


@interface Album (CoreDataGeneratedAccessors)
- (void)addPagesObject:(Page *)value;
- (void)removePagesObject:(Page *)value;
- (void)addPages:(NSSet *)value;
- (void)removePages:(NSSet *)value;

@end

