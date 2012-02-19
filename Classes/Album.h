//
//  Album.h
//  PhotoAlbums
//
//  Created by Gaurav on 20/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Page;

@interface Album : NSManagedObject

@property (nonatomic, retain) NSString * coverImagePath;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSDate * creationDate;
@property (nonatomic, retain) NSNumber * albumOrder;
@property (nonatomic, retain) NSNumber * hidden;
@property (nonatomic, retain) NSSet *pages;
@property (nonatomic, retain) NSString *albumID;

@end

@interface Album (CoreDataGeneratedAccessors)

- (void)addPagesObject:(Page *)value;
- (void)removePagesObject:(Page *)value;
- (void)addPages:(NSSet *)values;
- (void)removePages:(NSSet *)values;
@end
