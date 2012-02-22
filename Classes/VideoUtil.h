//
//  VideoUtil.h
//  PhotoAlbums
//
//  Created by Sourabh Raheja on 22/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <AVFoundation/AVAssetWriter.h>
#import "Album.h"
#import "Page.h"

@interface VideoUtil : NSObject

+ (NSString *) createVideoForAlbum: (Album *)album;
+ (NSString *) createVideoForPages: (NSArray *)pages;

@end
