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
	UITableView                                     *tableView;
	//model
	Album											*album;	
	
	Boolean											saveInProgress;
	
}

@property(nonatomic, retain) IBOutlet UILabel		*titleLabel;
@property(nonatomic, retain) IBOutlet UITextField	*nameTextField;
@property(nonatomic, retain) IBOutlet UISwitch		*hiddenSwitch;

@property(nonatomic, assign) Album					*album;
@property(nonatomic, assign) UITableView                                     *tableView;
- (IBAction) save: (id) sender;
- (IBAction) cancel: (id) sender;

@end
