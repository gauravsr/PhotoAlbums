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
@synthesize isPhotoSelectedForTheFirstTime;
@synthesize overlayOverTheSelectedImage;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
    }
    isPhotoSelectedForTheFirstTime = @"YES";  
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

-(BOOL)doToggling :(int)index {
    BOOL isSelected;
    if([isPhotoSelectedForTheFirstTime isEqualToString:@"YES"]) {
        isPhotoSelectedForTheFirstTime = @"NO";
        CGRect viewFrames = CGRectMake(0, 0, 75, 75);
        overlayOverTheSelectedImage = [[UIImageView alloc] initWithFrame:viewFrames];
        [overlayOverTheSelectedImage setImage:[UIImage imageNamed:@"Overlay.png"]];
        [self addSubview:overlayOverTheSelectedImage];
        isSelected = YES;
    }
    else {
        isPhotoSelectedForTheFirstTime = @"YES";
        [overlayOverTheSelectedImage removeFromSuperview];
        isSelected = NO;
    }
    
    return isSelected;
}

@end
