//
//  XImageView.h
//  PhotoAlbums
//
//  Created by Xebia India on 14/10/10.
//  Copyright Xebia IT Architects India Private Limited 2010. All rights reserved.
//

/// Custom Image View which can capture mouse down event and forward it to delegate
@interface XImageView : UIImageView {
	NSUInteger mIndex;
	id mDelegate;
}

@property (assign) NSUInteger index;
@property (assign) id delegate;

@end

#pragma mark - XImageView delegate

/// XImageView delegate interface
@interface NSObject (XImageViewDelegate)
/// Method called when an image view is selected.
- (void)imageViewDidSelected: (XImageView *)imageView atIndex: (int)index;

@end
