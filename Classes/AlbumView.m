//
//  Album.m
//  PhotoBook
//
//  Created by raheja on 14/06/10.
//  Copyright 2010 Xebia IT Architects India Private Limited. All rights reserved.
//

#import "AlbumView.h"


@implementation AlbumView


- (id)initWithFrame:(CGRect)frame 
{
    if (self = [super initWithFrame:frame]) 
	{
        // Initialization code
    }
    return self;
}


- (void)drawRect:(CGRect)rect 
{
    // Drawing code
}


- (void)dealloc 
{
    [super dealloc];
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if([self delegate] != nil)
    {
        [[self delegate] touchesEnded: touches withEvent: event];
    }
}


@end
