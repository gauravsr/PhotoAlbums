//
//  AlbumViewController.h
//  PhotoAlbums
//
//  Created by raheja on 18/08/10.
//  Copyright 2010 Xebia IT Architects India Private Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PhotoAlbumsAppDelegate.h"
#import "PhotoViewController.h"
#import "Album.h"
#import "Page.h"
#import "AlbumThumbnailView.h"
#import "ELCImagePickerController.h"

@interface AlbumViewController : UIViewController <ELCImagePickerControllerDelegate, 
                                                    UINavigationControllerDelegate, 
                                                    UIScrollViewDelegate,
                                                    UIActionSheetDelegate,
                                                    UIImagePickerControllerDelegate>
{	
	//model
	Album								*album;	
    NSMutableArray                      *referenceURLArray;
    NSMutableArray                      *selectedPagesWhileDoingBulkOperations;
//	PhotoViewController					*photoViewController;	
	
	//view
	IBOutlet UIImageView				*noPhotoView;
	IBOutlet UILabel					*noPhotoHeader;
	IBOutlet UILabel					*noPhotoDescription;
	IBOutlet UIActivityIndicatorView	*mActivityView;
	IBOutlet UIScrollView               *scrollview;
	IBOutlet AlbumThumbnailView			*albumThumbnailView;
    IBOutlet UIToolbar                  *toolbar;
    NSArray                             *existingToolbarItems;
    UIBarButtonItem                     *deleteButton;
    
	//NSMutableArray						*mThreadQueue;
	int									mPhotoSourceType;
    BOOL                                isPhotoAlreadyPresentInTheAlbum;
    BOOL                                isDeleteModeActive;
}

//model
@property (assign) Album						*album;

//view
@property (nonatomic, retain) UIImageView                   *noPhotoView;
@property (nonatomic, retain) UILabel                       *noPhotoHeader;
@property (nonatomic, retain) UILabel                       *noPhotoDescription;
@property (nonatomic, retain) AlbumThumbnailView            *albumThumbnailView;
@property (nonatomic, retain) IBOutlet UIScrollView         *scrollview;
@property (nonatomic, retain) IBOutlet UIToolbar            *toolbar;
@property (nonatomic, assign) NSArray                       *existingToolbarItems;
@property (nonatomic, assign) BOOL                          isDeleteModeActive;
@property (nonatomic, retain) UIBarButtonItem               *deleteButton;
// data
@property (nonatomic, retain) NSMutableArray            *referenceURLArray;
@property (nonatomic, retain) NSMutableArray            *selectedPagesWhileDoingBulkOperations;

//globals
- (NSString *) albumAudioDirectoryPath;
- (NSString	*) albumPhotoDirectoryPath;
- (NSManagedObjectContext *) applicationManagedObjectContext;

//methods
- (void) validate;
- (void) addPageForImage: (UIImage *) image;

- (IBAction) addPhoto: (id) sender;
- (IBAction) startSlideShow: (id) sender;
-(IBAction)handleBulkOperations:(id)sender;
- (void) addPhotoFromCamera;
@end
