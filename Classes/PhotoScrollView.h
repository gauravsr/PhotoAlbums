//
//  PhotoScrollView.h
//  PhotoAlbums
//
//  Created by Gaurav on 24/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Page.h"

@interface PhotoScrollView : UIScrollView <UIScrollViewDelegate> 
{
    UIImageView        *imageView;
    NSUInteger     index;
    Page			*page;
    BOOL			isLoaded;
}

@property (assign) BOOL isLoaded;

@property (assign) NSUInteger index;
@property (nonatomic, retain) Page *page;
@property (nonatomic, retain) UIImageView        *imageView;

- (void)displayImage:(UIImage *)image;
//- (void)displayTiledImageNamed:(NSString *)imageName size:(CGSize)imageSize;
- (void)setMaxMinZoomScalesForCurrentBounds;

//- (CGPoint)pointToCenterAfterRotation;
//- (CGFloat)scaleToRestoreAfterRotation;
- (void)restoreCenterPoint:(CGPoint)oldCenter scale:(CGFloat)oldScale;


@end
