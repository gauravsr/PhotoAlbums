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
#import "VideoUtil.h"
#import "FBConnect.h"
#import "FacebookPhotosViewController.h"

@interface AlbumViewController : UIViewController <ELCImagePickerControllerDelegate, 
                                                    UINavigationControllerDelegate, 
                                                    UIScrollViewDelegate,
                                                    UIActionSheetDelegate,
                                                    UIImagePickerControllerDelegate,
                                                    FBRequestDelegate, FBDialogDelegate, FBSessionDelegate>
{	
	//model
	Album								*album;	
    NSMutableArray                      *referenceURLArray;
    NSMutableArray                      *selectedPagesWhileDoingBulkOperations;
    Album *albumOfTypeTag;
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
    UIBarButtonItem                     *shareButton;
    NSMutableArray *facebookPhotos;
    FacebookPhotosViewController *facebookPhotosViewController;
    
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
@property (nonatomic, retain) Album *albumOfTypeTag;
@property (nonatomic, retain) AlbumThumbnailView            *albumThumbnailView;
@property (nonatomic, retain) IBOutlet UIScrollView         *scrollview;
@property (nonatomic, retain) IBOutlet UIToolbar            *toolbar;
@property (nonatomic, assign) NSArray                       *existingToolbarItems;
@property (nonatomic, assign) BOOL                          isDeleteModeActive;
@property (nonatomic, retain) UIBarButtonItem               *deleteButton;
@property (nonatomic, retain) UIBarButtonItem               *shareButton;

// data
@property (nonatomic, retain) NSMutableArray            *referenceURLArray;
@property (nonatomic, retain) NSMutableArray            *selectedPagesWhileDoingBulkOperations;
@property (nonatomic, retain) NSMutableArray *facebookPhotos;
@property (nonatomic, retain) FacebookPhotosViewController *facebookPhotosViewController;

//globals
- (NSString *) albumAudioDirectoryPath;
- (NSString	*) albumPhotoDirectoryPath;
- (NSManagedObjectContext *) applicationManagedObjectContext;

//methods
- (void) validate;
- (void) addPageForImage: (UIImage *) image;
- (void) addPhotoFromCamera;

- (IBAction) addPhoto: (id) sender;
- (IBAction) startSlideShow: (id) sender;
- (IBAction) handleBulkOperations:(id)sender;
- (IBAction) sharePhotos:(id)sender;

@end
