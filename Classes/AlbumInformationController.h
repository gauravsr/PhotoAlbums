//
//  AlbumInformationController.h
//  PhotoAlbums
//
//  Created by raheja on 01/10/10.
//  Copyright 2010 Xebia IT Architects India Private Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Album.h"

@interface AlbumInformationController : UIViewController <UITextFieldDelegate> 
{	
	//ui
	UILabel											*titleLabel;
	UITextField										*nameTextField;
	UISwitch										*hiddenSwitch;
    UISegmentedControl                              *typeControl;
    
	//model
	Album											*album;	
	
	Boolean											saveInProgress;
	
}

@property(nonatomic, retain) IBOutlet UILabel		*titleLabel;
@property(nonatomic, retain) IBOutlet UITextField	*nameTextField;
@property(nonatomic, retain) IBOutlet UISwitch		*hiddenSwitch;
@property(nonatomic, retain) IBOutlet UISegmentedControl *typeControl;

@property(nonatomic, assign) Album					*album;

- (IBAction) save: (id) sender;
- (IBAction) cancel: (id) sender;

@end
