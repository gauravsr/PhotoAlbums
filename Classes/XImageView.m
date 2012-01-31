//
//  XImageView.m
//  PhotoAlbums
//
//  Created by Xebia India on 14/10/10.
//  Copyright Xebia IT Architects India Private Limited 2010. All rights reserved.
//

#import "XImageView.h"


@implementation XImageView

@synthesize delegate = mDelegate;
@synthesize index = mIndex;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
    }
    
    return self;
}


- (void)drawRect:(CGRect)rect {
    // Drawing code
}


- (void)dealloc {
    [super dealloc];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    self.highlighted = YES;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	if(mDelegate){
		[mDelegate imageViewDidSelected: self atIndex: mIndex];
	}
}

- (BOOL)canBecomeFirstResponder{
	return YES;
}



//#pragma mark Public
//
//- (int)index{
//	return mIndex;
//}
//- (void)setIndex: (int)index{
//	mIndex = index;
//
//}
//
//- (id)delegate{
//	return mDelegate;
//}
//
//- (void)setDelegate: (id)delegate{
//	mDelegate = delegate;
//}

@end
