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
    
    return self;
}

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return pageView;
}

@end
