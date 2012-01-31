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
                                                    UIActionSheetDelegate>
{	
	//model
	Album								*album;	
    NSMutableArray                      *referenceURLArray;
//	PhotoViewController					*photoViewController;	
	
	//view
	IBOutlet UIImageView				*noPhotoView;
	IBOutlet UILabel					*noPhotoHeader;
	IBOutlet UILabel					*noPhotoDescription;
	IBOutlet UIActivityIndicatorView	*mActivityView;
	IBOutlet UIScrollView               *scrollview;
	IBOutlet AlbumThumbnailView			*albumThumbnailView;
	//NSMutableArray						*mThreadQueue;
	int									mPhotoSourceType;
    BOOL                                isPhotoAlreadyPresentInTheAlbum;
}

//model
@property (assign) Album						*album;

//view
@property (nonatomic, retain) UIImageView				*noPhotoView;
@property (nonatomic, retain) UILabel					*noPhotoHeader;
@property (nonatomic, retain) UILabel					*noPhotoDescription;
@property (nonatomic, retain) AlbumThumbnailView		*albumThumbnailView;
@property (nonatomic, retain) IBOutlet UIScrollView     *scrollview;
// data
@property (nonatomic, retain) NSMutableArray            *referenceURLArray;


//globals
- (NSString *) albumAudioDirectoryPath;
- (NSString	*) albumPhotoDirectoryPath;
- (NSManagedObjectContext *) applicationManagedObjectContext;

//methods
- (void) validate;
- (void) addPageForImage: (UIImage *) image;

- (IBAction) addPhoto: (id) sender;
- (IBAction) startSlideShow: (id) sender;
- (void) addPhotoFromCamera;
@end
