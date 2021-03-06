//
//  AlbumThumbnailView.h
//  PhotoAlbums
//
//  Created by raheja on 08/10/10.
//  Copyright 2010 Xebia IT Architects India Private Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Album.h"
#import "PhotoRepository.h"
#import "XImageView.h"

@interface AlbumThumbnailView : UIScrollView {
	
	NSMutableDictionary								*thumbailDictionary;
	PhotoRepository									*photoRepository;
	id mEventDelegate;
}

@property (nonatomic, retain) NSMutableDictionary	*thumbailDictionary;
@property (nonatomic, retain) PhotoRepository		*photoRepository;
@property (assign) id eventDelegate;

- (void) validate: (NSArray *)pages;


@end

#pragma mark AlbumThumbnailView delegate

@interface NSObject (AlbumThumbnailViewDelegate)

// Method called when a thumbnail gets selected.
- (void)thumbnailView:(XImageView *)image didSelectedIndex:(int)index;

@end
