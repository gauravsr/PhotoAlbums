//
//  Page.m
//  PhotoAlbums
//
//  Created by Sourabh Raheja on 22/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Page.h"
#import "Album.h"
#import "PhotoAlbumsAppDelegate.h"

@implementation Page

@synthesize pageID, audioNoteURL;

@dynamic audioNotePath;
@dynamic textCaption;
@dynamic creationDate;
@dynamic imageThumbnailPath;
@dynamic pageOrder;
@dynamic imagePath;
@dynamic album;


- (NSString *) pageID
{
	if(!pageID)
	{
		NSManagedObjectID *objectID = [self objectID];
		NSURL *url = [objectID URIRepresentation];
		NSString *path = [url path];
		
		NSArray *pathComponents = [path componentsSeparatedByString:@"/"];
		self.pageID = [pathComponents lastObject];
	}
	
	return pageID;
}

- (BOOL) hasAudioNote
{
	if(!self.audioNotePath)
	{
		return NO;
	}
	else
	{
		return YES;
	}
}

- (NSURL *) audioNoteURL
{
	//if(!audioNoteURL)
	{
		NSString *applicationDocumentDirPath = [(PhotoAlbumsAppDelegate *)[[UIApplication sharedApplication] delegate] applicationDocumentsDirectory];
		NSString *absolutePath = [NSString stringWithFormat:@"%@/%@", applicationDocumentDirPath, self.audioNotePath];
		CFStringRef fileString = (CFStringRef) absolutePath;
		
		// create the file URL that identifies the file that the recording audio queue object records into
		CFURLRef fileURL =	CFURLCreateWithFileSystemPath (		 
														   NULL,
														   fileString,
														   kCFURLPOSIXPathStyle,
														   false
														   );
		
		NSLog (@"Recorded file path: %@", fileURL); // shows the location of the recorded file
		
		// save the sound file URL as an object attribute (as an NSURL object)
		if (fileURL) 
		{
			self.audioNoteURL	= (NSURL *) fileURL;
			CFRelease (fileURL);
		}		
	}
	
	return audioNoteURL;
}

@end
