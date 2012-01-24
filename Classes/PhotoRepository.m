//
//  PhotoRepository.m
//  PhotoAlbums
//
//  Created by raheja on 03/10/10.
//  Copyright 2010 Xebia IT Architects India Private Limited. All rights reserved.
//

#import "PhotoRepository.h"
#import "PhotoAlbumsAppDelegate.h"

@implementation PhotoRepository

static PhotoRepository *singletonInstance = nil;
NSMutableDictionary *photoDictionary;

- (id)init
{
	if(self = [super init])
	{
		photoDictionary = [[NSMutableDictionary alloc] init];
	}
	return self;
}

+ (PhotoRepository *) instance
{
	@synchronized(self) 
	{
		if(!singletonInstance) 
		{
			singletonInstance = [[PhotoRepository alloc] init];
		}
	}
	return singletonInstance;
}

- (UIImage *) getPhoto: (NSString *)photoID
{
	UIImage *photo = [photoDictionary objectForKey:photoID];
	if(!photo)
	{
		NSString *applicationDocumentDirPath = [(PhotoAlbumsAppDelegate *)[[UIApplication sharedApplication] delegate] applicationDocumentsDirectory];
		NSString *imagePath = [NSString stringWithFormat:@"%@/%@",applicationDocumentDirPath, photoID];
		if ([[NSFileManager defaultManager] fileExistsAtPath:imagePath]) 
		{
			photo = [[UIImage alloc] initWithContentsOfFile:imagePath];		
			[photoDictionary setObject:photo forKey:photoID];
		}
	}
	return photo;
}

- (void) addPhoto:(UIImage *)photo withPhotoID:(NSString *)photoID
{
	UIImage *existingPhoto = [photoDictionary objectForKey:photoID];
	if(!existingPhoto)
	{
		[photoDictionary setObject:photo forKey:photoID];
	}		
}

@end
