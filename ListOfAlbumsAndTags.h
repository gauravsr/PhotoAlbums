//
//  ListOfAlbumsAndTags.h
//  PhotoAlbums
//
//  Created by Gaurav on 20/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ListOfAlbumsAndTags : NSManagedObject

@property (nonatomic, assign) BOOL           hidden;
@property (nonatomic, retain) NSDate		*creationDate;
@property (nonatomic, retain) NSString		*sorter;


@end
