//
//  ScrollViewForPageView.h
//  PhotoAlbums
//
//  Created by Gaurav on 13/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PageView.h"

@interface ScrollViewForPageView : UIScrollView <UIScrollViewDelegate> {
    PageView *pageView;
}

@property (nonatomic, retain) PageView *pageView;

-(id)addImage:(UIImage *)image;

@end
