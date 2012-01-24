//
//  PageView.m
//  PhotoBook
//
//  Created by raheja on 11/06/10.
//  Copyright 2010 Xebia IT Architects India Private Limited. All rights reserved.
//

#import "PageView.h"


@implementation PageView

@synthesize page, isLoaded;

- (void) initializeProperties
{
	[self setContentMode:UIViewContentModeScaleAspectFit];		
}

- (id) initWithImage: (UIImage *) img
{
	self = [super initWithImage:img];
	if (self != nil) 
	{
		[self initializeProperties];	
	}
	return self;
}

- (id) init {
	self = [super init];
	if (self != nil) 
	{
		[self initializeProperties];
	}
	return self;	
}

- (void) dealloc
{
	[page release];
	[super dealloc];

}

@end
