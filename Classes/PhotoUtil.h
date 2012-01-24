//
//  PhotoUtil.h
//  PhotoAlbums
//
//  Created by raheja on 01/10/10.
//  Copyright 2010 Xebia IT Architects India Private Limited. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface PhotoUtil : NSObject {

}

+ (UIImage *)scalePhoto: (UIImage *)photo toSize: (CGSize)size cropToFit: (BOOL) crop;
+ (UIImage *)scalePhoto: (UIImage *)photo toSize: (CGSize)size;
+ (UIImage *)cropPhoto: (UIImage *)photo toRect: (CGRect)rect;

+ (UIImage *)createThumbnail: (UIImage *)photo;
+ (UIImage *)createSnapshot: (UIImage *)photo;
+ (UIImage *)createHighRes: (UIImage *)photo;

@end
