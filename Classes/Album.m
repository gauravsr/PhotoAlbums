//
//  Album.m
//  PhotoAlbums
//
//  Created by Sourabh Raheja on 22/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Album.h"
#import "Page.h"



@implementation Album

@synthesize albumID, sectionType;

@dynamic isTag;
@dynamic hidden;
@dynamic creationDate;
@dynamic coverImagePath;
@dynamic title;
@dynamic albumOrder;
@dynamic pages;

- (NSString *) albumID
{
	if(!albumID)
	{
		NSManagedObjectID *objectID = [self objectID];
		NSURL *url = [objectID URIRepresentation];
		NSString *path = [url path];
		
		NSArray *pathComponents = [path componentsSeparatedByString:@"/"];
		self.albumID = [pathComponents lastObject];
	}
	
	return albumID;
}

- (NSString *) sectionType {
    NSString *type = @"Album";
    if(self.isTag.integerValue == 1) {
        type = @"Tag";
    }
    
    return type;
}


@end
