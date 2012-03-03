//
//  OverlayViewController.h
//  PhotoAlbums
//
//  Created by Gaurav on 03/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AlbumListViewController.h"

@class AlbumListViewController;

@interface OverlayViewController : UIViewController
{
    AlbumListViewController *viewController;
}

@property (nonatomic, retain) AlbumListViewController *viewController;

@end
