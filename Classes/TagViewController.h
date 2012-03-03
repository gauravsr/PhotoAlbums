//
//  TagViewController.h
//  PhotoAlbums
//
//  Created by Gaurav on 01/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Album.h"
#import "PhotoViewController.h"

@class PhotoViewController;

@interface TagViewController : UIViewController <UITableViewDataSource, 
                                                    UITableViewDelegate,
                                                    UITextFieldDelegate> {
                                                        
    Album *albumOfTypeTag;
    IBOutlet UITextField *tagTitle;
    NSArray *fetchedTagsFromCoredata;
    IBOutlet UIScrollView *scrollView;
    UITableView *tableViewForShowingAvailableTags;
    NSMutableArray *matchingTags;
    PhotoViewController *viewController;
    int currentPageIndex;
}

@property (nonatomic, retain) Album *albumOfTypeTag;
@property (nonatomic, retain) PhotoViewController *viewController;
@property (nonatomic, retain) IBOutlet UITextField *tagTitle;
@property (nonatomic, retain) NSArray *fetchedTagsFromCoredata;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UITableView *tableViewForShowingAvailableTags;
@property (nonatomic, retain) NSMutableArray *matchingTags;
@property (nonatomic) int currentPageIndex;

-(IBAction)addTagHandler:(id)sender;

@end
