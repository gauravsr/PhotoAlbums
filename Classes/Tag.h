//
//  Tag.h
//  PhotoAlbums
//
//  Created by Gaurav on 22/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "ListOfAlbumsAndTags.h"

@class Page;

@interface Tag : ListOfAlbumsAndTags

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) Page *page;

@end
