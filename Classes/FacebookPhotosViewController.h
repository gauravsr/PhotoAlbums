//
//  FacebookPhotosViewController.h
//  PhotoAlbums
//
//  Created by Gaurav on 03/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FacebookPhotosViewController : UIViewController {
    IBOutlet UIActivityIndicatorView *activityIndicator;
    
    NSMutableArray *list;
}

@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, retain) NSMutableArray *list;

-(void)show;

@end