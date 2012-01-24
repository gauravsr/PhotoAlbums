//
//  PhotoRepository.h
//  PhotoAlbums
//
//  Created by raheja on 03/10/10.
//  Copyright 2010 Xebia IT Architects India Private Limited. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface PhotoRepository : NSObject {
}

+ (PhotoRepository *) instance;

- (UIImage *) getPhoto: (NSString *)photoID;
- (void) addPhoto:(UIImage *)photo withPhotoID:(NSString *)photoID;

@end
