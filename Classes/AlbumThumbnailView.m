//
//  AlbumThumbnailView.m
//  PhotoAlbums
//
//  Created by raheja on 08/10/10.
//  Copyright 2010 Xebia IT Architects India Private Limited. All rights reserved.
//

#import "AlbumThumbnailView.h"
#import "Page.h"
#import "PhotoUtil.h"
#import "PhotoAlbumsAppDelegate.h"
#import "XImageView.h"

@implementation AlbumThumbnailView

@synthesize thumbailDictionary, photoRepository;
@synthesize eventDelegate = mEventDelegate;


static NSInteger THUMBNAIL_WIDTH	= 75;
static NSInteger THUMBNAIL_HEIGHT	= 75;
static NSInteger THUMBNAIL_PADDING	= 4;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code		
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
	
	if(!thumbailDictionary)
	{
		thumbailDictionary = [[NSMutableDictionary alloc] init];
	}
	if(!photoRepository)
	{
		photoRepository = [PhotoRepository instance];		
	}
}

- (void) validate: (NSArray *) pages
{
	NSArray *subViews = [self subviews];
	unsigned i = 0;
	for(; i < [subViews count]; i++){
		UIView *aSubView = [subViews objectAtIndex:i];
		[aSubView removeFromSuperview];
	}
	
	photoRepository = [PhotoRepository instance];		

	unsigned pageCount = [pages count];
	
	int contentHeight =  ((pageCount - 1)/4 + 1) * (THUMBNAIL_HEIGHT + THUMBNAIL_PADDING) + THUMBNAIL_PADDING;
	
	[self setContentSize:CGSizeMake(self.frame.size.width, contentHeight)];
	
	Page *page;
	XImageView *thumbnailImageView;
	UIImage *thumbnailImage;
	int row = 0, column = 0;
	int x,y;

	for(unsigned i = 0; i < pageCount; i++)
	{
		page = [pages objectAtIndex:i];
		thumbnailImageView = [thumbailDictionary objectForKey: page.imageThumbnailPath];
		if(!thumbnailImageView)
		{
			thumbnailImage = [photoRepository getPhoto: page.imageThumbnailPath];
			if(!thumbnailImage)
			{
				thumbnailImage = [photoRepository getPhoto: page.imagePath];
				thumbnailImage =  [PhotoUtil createThumbnail:thumbnailImage];
				[photoRepository addPhoto:thumbnailImage withPhotoID:page.imageThumbnailPath];
				
				//creting thumbnail image if its already not there
				NSData *thumbnailData = [NSData dataWithData:UIImagePNGRepresentation(thumbnailImage)];	
				[thumbnailData writeToFile:page.imageThumbnailPath atomically:NO];			
			}		
			
			thumbnailImageView = [[XImageView alloc] init];
			[thumbnailImageView setIndex: i];
			[thumbnailImageView setDelegate: self];
			[thumbnailImageView setUserInteractionEnabled:YES];
			row = i / 4;
			column = i % 4;
			x = (THUMBNAIL_WIDTH + THUMBNAIL_PADDING)*column + THUMBNAIL_PADDING;
			y = (THUMBNAIL_WIDTH + THUMBNAIL_PADDING)*row + THUMBNAIL_PADDING;
			[thumbnailImageView setFrame:CGRectMake(x, y, THUMBNAIL_WIDTH, THUMBNAIL_HEIGHT)];
			[thumbnailImageView setImage:thumbnailImage];
			if([page hasAudioNote]){
				UIImageView *soundImageView = [[UIImageView alloc]initWithFrame:CGRectMake(2, THUMBNAIL_HEIGHT - 26, 24, 24)];
				[soundImageView setImage:[UIImage imageNamed:@"Sound.png"]];			
				[thumbnailImageView addSubview: soundImageView];
				[soundImageView release];
			}
			
			[self addSubview:thumbnailImageView];
			[thumbnailImageView release];
			
			
			//[self.thumbailDictionary setObject:thumbnailImageView forKey:page.imageThumbnailPath];
		}
	}
	[self setNeedsDisplay];
}

- (void)dealloc {
	//clean up the thumbnailViews and thumbnails from repository
	[thumbailDictionary release];
    [super dealloc];
}

#pragma mark XImageView delegate implementation

- (void)imageViewDidSelected: (XImageView *)imageView atIndex: (int)index{
	[mEventDelegate thumbnailView:imageView didSelectedIndex:index];
}

@end

#pragma mark- 

@implementation NSObject (AlbumThumbnailViewDelegate)

// Method called when a thumbnail gets selected.
- (void)thumbnailView:(XImageView *)image didSelectedIndex: (int)index{

}

@end

