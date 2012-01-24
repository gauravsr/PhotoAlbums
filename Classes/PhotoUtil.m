//
//  PhotoUtil.m
//  PhotoAlbums
//
//  Created by raheja on 01/10/10.
//  Copyright 2010 Xebia IT Architects India Private Limited. All rights reserved.
//

#import "PhotoUtil.h"

@implementation PhotoUtil

static NSInteger THUMBNAIL_WIDTH	= 75;
static NSInteger THUMBNAIL_HEIGHT	= 75;

static NSInteger SNAPSHOT_WIDTH		= 640;
static NSInteger SNAPSHOT_HEIGHT	= 960;

static NSInteger HIGHRES_WIDTH		= 800;
static NSInteger HIGHRES_HEIGHT		= 800;


UIImage* resizedImage(UIImage *inImage, CGRect thumbRect)
{
	CGImageRef			imageRef = [inImage CGImage];
	CGImageAlphaInfo	alphaInfo = CGImageGetAlphaInfo(imageRef);
	
	// There's a wierdness with kCGImageAlphaNone and CGBitmapContextCreate
	// see Supported Pixel Formats in the Quartz 2D Programming Guide
	// Creating a Bitmap Graphics Context section
	// only RGB 8 bit images with alpha of kCGImageAlphaNoneSkipFirst, kCGImageAlphaNoneSkipLast, kCGImageAlphaPremultipliedFirst,
	// and kCGImageAlphaPremultipliedLast, with a few other oddball image kinds are supported
	// The images on input here are likely to be png or jpeg files
	if (alphaInfo == kCGImageAlphaNone)
		alphaInfo = kCGImageAlphaNoneSkipLast;
	

	// Build a bitmap context that's the size of the thumbRect
	CGContextRef bitmap = CGBitmapContextCreate(
												NULL,
												thumbRect.size.width,		// width
												thumbRect.size.height,		// height
												CGImageGetBitsPerComponent(imageRef),	// really needs to always be 8
												4 * thumbRect.size.width,	// rowbytes
												CGImageGetColorSpace(imageRef),
												alphaInfo
												);
	
	CGContextSetInterpolationQuality(bitmap, kCGInterpolationHigh);

	// Draw into the context, this scales the image
	CGContextDrawImage(bitmap, thumbRect, imageRef);
	// Get an image from the context and a UIImage
	CGImageRef	ref = CGBitmapContextCreateImage(bitmap);
	UIImage*	result = [UIImage imageWithCGImage:ref];
	
	CGContextRelease(bitmap);	// ok if NULL
	CGImageRelease(ref);
	
	return result;
}

+ (UIImage *)cropPhoto: (UIImage *)photo 
				toRect: (CGRect)rect
{
	//Yet to validate
	CGImageRef croppedCGImage =  CGImageCreateWithImageInRect([photo CGImage], rect); 
	return [UIImage imageWithCGImage:croppedCGImage];
}

+ (UIImage *)scalePhoto: (UIImage *)photo 
				 toSize: (CGSize)size 
			  cropToFit: (BOOL)crop
{
	double scaledWidth = size.width;
	double scaledHeight = size.height;

	double photoWidth = photo.size.width;
	double photoHeight = photo.size.height;	
	
	double aspectRatio;
	if(photoHeight != 0)
	{
		aspectRatio = photoWidth / photoHeight;			
	}
	else
	{
		aspectRatio = 1;			
	}
	
	if(crop == YES)
	{
		if(aspectRatio > 1)
		{
			scaledHeight = size.height;
			scaledWidth = aspectRatio * scaledHeight;
		}
		else
		{
			scaledWidth = size.width;
			scaledHeight = scaledWidth / aspectRatio;
		}
	}
	else
	{
		if(aspectRatio < 1)
		{
			scaledHeight = size.height;
			scaledWidth = aspectRatio * scaledHeight;
		}
		else
		{
			scaledWidth = size.width;
			scaledHeight = scaledWidth / aspectRatio;
		}
	}
	
	CGRect rect = CGRectMake(0.0, 0.0, scaledWidth, scaledHeight);	
//	UIImage *scaledPhoto = resizedImage(photo, rect);
	UIGraphicsBeginImageContext(rect.size);	
	[photo drawInRect:rect];
	UIImage *scaledPhoto = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();	
	
	int x = floor( (scaledWidth - size.width) / 2 );
	int y = floor( (scaledHeight - size.height) / 2);
	
	CGRect cropRect = CGRectMake(x ,y , size.width, size.height);	
	return [self cropPhoto:scaledPhoto toRect:cropRect];
}

//Implementing default value of cropToImage to NO
+ (UIImage *)scalePhoto: (UIImage *)photo 
				 toSize: (CGSize)size
{
	return [self scalePhoto:photo toSize:size cropToFit:NO];
}

+ (UIImage *)createThumbnail: (UIImage *)photo
{
	
	CGSize size = CGSizeMake(THUMBNAIL_WIDTH, THUMBNAIL_HEIGHT);
	return [self scalePhoto:photo toSize:size cropToFit:YES];
}

+ (UIImage *)createSnapshot: (UIImage *)photo
{
	CGSize size = CGSizeMake(SNAPSHOT_WIDTH, SNAPSHOT_HEIGHT);
	return [self scalePhoto:photo toSize:size cropToFit:NO];
}

+ (UIImage *)createHighRes: (UIImage *)photo
{
	CGSize size = CGSizeMake(HIGHRES_WIDTH, HIGHRES_HEIGHT);
	return [self scalePhoto:photo toSize:size cropToFit:NO];
}

@end
