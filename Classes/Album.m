// 
//  Album.m
//  PhotoAlbums
//
//  Created by raheja on 29/06/10.
//  Copyright 2010 Xebia IT Architects India Private Limited. All rights reserved.
//

#import "Album.h"

#import "Page.h"

@implementation Album 

@synthesize albumID;

@dynamic coverImagePath;
@dynamic title;
@dynamic albumOrder;
@dynamic pages;
@dynamic albumPath;

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

- (void) dealloc
{
	[super dealloc];
}


@end
