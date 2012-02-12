//
//  ScrollViewForPageView.m
//  PhotoAlbums
//
//  Created by Gaurav on 13/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ScrollViewForPageView.h"

@implementation ScrollViewForPageView

@synthesize pageView;

-(id)addImage:(UIImage *)image {
    pageView = [[PageView alloc] initWithImage:image];
    [self addSubview:pageView];
    self.maximumZoomScale = 2;
    self.minimumZoomScale = 0.5;
    self.delegate = self;
    
    self.zoomScale = self.minimumZoomScale;
    return self;
}

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return pageView;
}

- (void)layoutSubviews 
{
    [super layoutSubviews];
    
    // center the image as it becomes smaller than the size of the screen
    
    CGSize boundsSize = self.bounds.size;
    CGRect frameToCenter = pageView.frame;
    
    // center horizontally
    if (frameToCenter.size.width < boundsSize.width)
        frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
    else
        frameToCenter.origin.x = 0;
    
    // center vertically
    if (frameToCenter.size.height < boundsSize.height)
        frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
    else
        frameToCenter.origin.y = 0;
    
    pageView.frame = frameToCenter;
}



@end
