//
//  AlbumViewController.m
//  PhotoAlbums
//
//  Created by raheja on 18/08/10.
//  Copyright 2010 Xebia IT Architects India Private Limited. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "AlbumViewController.h"
#import "AlbumInformationController.h"
#import "PhotoUtil.h"
#import "PhotoRepository.h"
#import "ELCAlbumPickerController.h"
#import "PhotoAlbumsAppDelegate.h"
#import "PageView.h"
#import "XImageView.h"

#define ZOOM_VIEW_TAG 100
#define ZOOM_STEP 1.5

#define THUMB_HEIGHT 150
#define THUMB_V_PADDING 10
#define THUMB_H_PADDING 10
#define CREDIT_LABEL_HEIGHT 20

#define AUTOSCROLL_THRESHOLD 30

@implementation AlbumViewController

@synthesize album;
//@synthesize photoViewController;
@synthesize noPhotoView;
@synthesize noPhotoHeader, noPhotoDescription;
@synthesize albumThumbnailView;
@synthesize scrollview;
@synthesize referenceURLArray;
@synthesize isDeleteModeActive;
@synthesize toolbar;
@synthesize existingToolbarItems;
@synthesize selectedPagesWhileDoingBulkOperations;
@synthesize deleteButton;
@synthesize albumOfTypeTag;

/************************************************
 *					Globals						*
 ***********************************************/

- (void)createDirectoryAtpath: (NSString *)aPath{
	
	NSFileManager *fileManager = [NSFileManager defaultManager]; 
	BOOL isDir=YES;
	
	if(![fileManager fileExistsAtPath:aPath isDirectory:&isDir])
	{
		[fileManager createDirectoryAtPath:aPath withIntermediateDirectories:YES attributes:nil error:nil];
	}
	
}

/**
 Returns the path to the application's Documents directory.
 */
- (NSString *) albumAudioDirectoryPath 
{
	NSString *audioDirectoryPath = [NSString stringWithFormat:@"%@/audio", /*VJ - documentsDirectoryPath,*/album.albumID];
	
	
	return audioDirectoryPath;
}

/**
 Returns the path to the application's Documents directory.
 */
- (NSString *) albumPhotoDirectoryPath 
{
	NSString *photoDirectoryPath = [NSString stringWithFormat:@"%@/photo", album.albumID];
	return photoDirectoryPath;
}

/**
 Returns application's ManagedObjectContext.
 */
- (NSManagedObjectContext *) applicationManagedObjectContext 
{
	PhotoAlbumsAppDelegate *appDelegate = (PhotoAlbumsAppDelegate *)[[UIApplication sharedApplication] delegate];	
	return [appDelegate managedObjectContext];
}

/************************************************
 *					View Operations				*
 ***********************************************/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
    [super viewDidLoad];
	//mThreadQueue = [NSMutableArray new];
	[mActivityView setHidden:YES];
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editAlbum)];
    self.navigationItem.rightBarButtonItem = editButton;
    [editButton release];
	self.albumThumbnailView.eventDelegate = self;
    self.referenceURLArray = [NSMutableArray array];
    isPhotoAlreadyPresentInTheAlbum = NO;
    isDeleteModeActive = NO;
    selectedPagesWhileDoingBulkOperations = [[NSMutableArray array] retain];
}

- (void)viewWillAppear:(BOOL)animated 
{
	[super viewWillAppear:animated];
	
	self.title = album.title;
	[self validate];
}

- (void)didReceiveMemoryWarning 
{
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload 
{
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc 
{
	//[mThreadQueue release];
	[noPhotoView release];
	[noPhotoDescription release];
	[noPhotoHeader release];
	[albumThumbnailView release];
    //[photoViewController release];
	[super dealloc];
}

/************************************************
 *					Album Operations			*
 ***********************************************/
- (void) validate
{
	BOOL noPhoto = ([album.pages count] == 0);
	
	[albumThumbnailView setHidden:noPhoto];
	if(noPhoto == NO)
	{	
		NSArray *pages = [self.album.pages allObjects];
		NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"creationDate" ascending:YES];
		pages = [pages sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
		[sortDescriptor release];
		
		[albumThumbnailView validate: pages];
	}
	
	[noPhotoView setHidden:!noPhoto];
	[noPhotoHeader setHidden:!noPhoto];
	[noPhotoDescription setHidden:!noPhoto];	
}

- (void) saveAlbum
{
	// Save the context.
    NSError *error = nil;
    if (![[self applicationManagedObjectContext] save:&error]) 
	{
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
    }	
}

- (void) addPageForImage: (UIImage *)image
{
	NSManagedObjectContext *context = [self applicationManagedObjectContext];
	Page *newPage = [NSEntityDescription insertNewObjectForEntityForName:@"Page" inManagedObjectContext:context];
	
	//configure the new managed object.
	[newPage addAlbumObject:self.album];
	[newPage setValue:[NSDate date] forKey:@"creationDate"];	
	
	UIImage *scaledImage = [PhotoUtil createSnapshot:image];
	image = scaledImage;
	NSString *applicationDocumentDirPath = [(PhotoAlbumsAppDelegate *)[[UIApplication sharedApplication] delegate] applicationDocumentsDirectory];
	NSString *localImagePath = [NSString stringWithFormat:@"%@/%@",[self albumPhotoDirectoryPath], [newPage pageID]];
	NSString *imageDirectoryPath = 	[NSString stringWithFormat:@"%@/%@",applicationDocumentDirPath, [self albumPhotoDirectoryPath]];
	NSString *imagePath = [NSString stringWithFormat:@"%@/%@",applicationDocumentDirPath, localImagePath];
	NSString *localImageThumbnailPath = [NSString stringWithFormat:@"%@/%@.thumbnail",[self albumPhotoDirectoryPath], [newPage pageID]];
	NSString *imageThumbnailPath = [NSString stringWithFormat:@"%@/%@",applicationDocumentDirPath, localImageThumbnailPath];

	[self createDirectoryAtpath: imageDirectoryPath];
	
	UIImage *thumbnailImage = [PhotoUtil createThumbnail:image];	
	NSData *thumbnailData = [NSData dataWithData:UIImagePNGRepresentation(thumbnailImage)];	
	BOOL thumbnailWriteSuccessFul = [thumbnailData writeToFile:imageThumbnailPath atomically:NO];
	
	NSData *imageData = [NSData dataWithData:UIImagePNGRepresentation(image)];
	BOOL writeSuccessFul = [imageData writeToFile:imagePath atomically:NO];
	
	if(writeSuccessFul)
	{
		//add page to album
		[self.album addPagesObject:newPage];
		[newPage setValue:localImagePath forKey:@"imagePath"];
		[newPage setValue:localImageThumbnailPath forKey:@"imageThumbnailPath"];
		
		[[PhotoRepository instance] addPhoto:image withPhotoID:localImagePath];
		
		if(thumbnailWriteSuccessFul)
		{
			[[PhotoRepository instance] addPhoto:thumbnailImage withPhotoID:localImageThumbnailPath];
		}else {
			NSLog(@"Thumbnail Write Failed");
		}
		
	}
	
	[self saveAlbum];
	[self validate];
    
	//TBD release objects
}

-(void) editAlbum
{
	AlbumInformationController *albumInformationController = [[AlbumInformationController alloc] init];
	albumInformationController.album = self.album;
	
	[self presentModalViewController:albumInformationController animated:true];
    [albumInformationController release];	
}

#pragma mark ELCImagePickerControllerDelegate Methods

/************************************************
 *					Add Photo Operations		*
 ***********************************************/

- (IBAction) addPhoto: (id) sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"Please select from the following options:" 
                                                        delegate:self 
                                                        cancelButtonTitle:@"Cancel" 
                                                        destructiveButtonTitle:nil 
                                                        otherButtonTitles:@"Camera", @"Photo Gallery", nil];
    
	actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    actionSheet.delegate = self;
	[actionSheet showInView:self.view]; 
	[actionSheet release];
}

-(void)addPhotoFromPhotoGallery {
    ELCAlbumPickerController *albumController = [[ELCAlbumPickerController alloc] init];
    ELCImagePickerController *elcPicker = [[ELCImagePickerController alloc] initWithRootViewController:albumController];

    [albumController setParent:elcPicker];
    [elcPicker setDelegate:self];

    [self presentModalViewController:elcPicker animated:YES];
    [elcPicker release];
    [albumController release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
	if(buttonIndex == 0){
        [self addPhotoFromCamera];
	}
	else if(buttonIndex == 1){
        [self addPhotoFromPhotoGallery];
	}
}



- (void)elcImagePickerController:(ELCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info {

    [self dismissModalViewControllerAnimated:YES];
    
	for(NSDictionary *dict in info) {
                NSURL *referenceURL = [dict objectForKey:@"UIImagePickerControllerReferenceURL"];
        
        if([referenceURLArray containsObject:referenceURL]) {
            isPhotoAlreadyPresentInTheAlbum = YES;
        }
        [referenceURLArray addObject:referenceURL];
        
        UIImage *image = [dict objectForKey:UIImagePickerControllerOriginalImage];
        UIImage *selectedImage = [[UIImage alloc] initWithCGImage:image.CGImage];
        
        [self addPageForImage:selectedImage];

	}
    
    if(isPhotoAlreadyPresentInTheAlbum) {
	
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Duplicate photos"
                                                      message:@"This album contains duplicate photos."
                                                     delegate:nil
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
    
        [message show];
    }
}

- (void)elcImagePickerControllerDidCancel:(ELCImagePickerController *)picker {
    
	[self dismissModalViewControllerAnimated:YES];
}

- (void) imagePickerController: (UIImagePickerController *)imagePicker didFinishPickingImage:(UIImage *) image
				   editingInfo: (NSDictionary *) editingInfo
{
	UIImage *selectedImage = [[UIImage alloc] initWithCGImage:image.CGImage];		
	
	[self addPageForImage:selectedImage];

	[selectedImage release];
	if (mPhotoSourceType == UIImagePickerControllerSourceTypeCamera) {
		[imagePicker dismissModalViewControllerAnimated:YES];
	}
}

- (void) imagePickerControllerDidCancel: (UIImagePickerController *) imagePicker
{
	[imagePicker dismissModalViewControllerAnimated:YES];
	[mActivityView setHidden:NO];
	[mActivityView startAnimating];
}

- (void) addPhotoFromCamera {
    //UIImagePickerControllerMediaMetadata
    
	if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
	{
		UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
		imagePicker.delegate = self;
		imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
		imagePicker.allowsEditing = NO;
		mPhotoSourceType = UIImagePickerControllerSourceTypeCamera;
		[self presentModalViewController:imagePicker animated:YES];
		
		[imagePicker release];
	}else{
		
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Camera not found!"
                                                          message:@"Your device do not have a Camera."
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        
        [message show];
	}
}

- (void) fileWriteThreadDidEndExecution: (id)sender{
	[mActivityView setHidden:YES];
	[mActivityView stopAnimating];
}

#pragma mark Slide show methods
/************************************************
 *					SlideShow Operations		*
 ***********************************************/

- (PhotoViewController *) preparePhotoViewController {
	PhotoViewController *aViewController = [[PhotoViewController alloc] init];
	aViewController.album = self.album;
    
	NSString *applicationDocumentDirPath = [(PhotoAlbumsAppDelegate *)[[UIApplication sharedApplication] delegate] applicationDocumentsDirectory];
	NSString *imageDirectoryPath = 	[NSString stringWithFormat:@"%@/%@",applicationDocumentDirPath, [self albumPhotoDirectoryPath]];
	NSString *audioDirectoryPath = [NSString stringWithFormat:@"%@/%@",applicationDocumentDirPath, [self albumAudioDirectoryPath]];
	[self createDirectoryAtpath:imageDirectoryPath];
	[self createDirectoryAtpath:audioDirectoryPath];
	aViewController.albumAudioDirectoryPath = imageDirectoryPath;
	aViewController.albumPhotoDirectoryPath = audioDirectoryPath;
	aViewController.applicationManagedObjectContext = [self applicationManagedObjectContext];		

    aViewController.slideshowMode = NO;
    
    return aViewController;
}

- (IBAction) startSlideShow: (id) sender {
    if([[self.album pages] count] > 0)
    {
        PhotoViewController *aViewController = [self preparePhotoViewController];
        aViewController.selectedIndex = 0;
        aViewController.slideshowMode = YES;
        
        [self.navigationController pushViewController:aViewController animated:YES];
        [aViewController release];        
    } else 
    {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"No photos found."
                                                          message:@"This album contains no photos."
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil]; 
        [message show];
    }
}

- (void)thumbnailView:(XImageView *)image didSelectedIndex:(int)index {
    if(isDeleteModeActive) {
        
        NSArray *pages = [self.album.pages allObjects];
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"creationDate" ascending:YES];
        pages = [pages sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
        [sortDescriptor release];
        Page *page = [pages objectAtIndex:index];
        
        BOOL isSelected = [image doToggling:index];
        
        if(isSelected) {
            [selectedPagesWhileDoingBulkOperations addObject:page];
        }
        else {
            [selectedPagesWhileDoingBulkOperations removeObject:page];
        }
        NSString *numberOfItemsSelected = [NSString stringWithFormat:@"%d", [selectedPagesWhileDoingBulkOperations count]];
        NSMutableString *deleteButtonLabel = [NSMutableString stringWithString:@"Delete ("];
        [deleteButtonLabel appendString:numberOfItemsSelected];
        [deleteButtonLabel appendString:@")"];
        
        [deleteButton setTitle:deleteButtonLabel];
                
        if([numberOfItemsSelected isEqualToString:@"0"]) {
            [deleteButton setTitle:@"Delete"];
        }
        
    }
    else {
        PhotoViewController *photoViewController = [self preparePhotoViewController];
        photoViewController.selectedIndex = index;
        photoViewController.albumOfTypeTag = self.albumOfTypeTag;
        
        [self.navigationController pushViewController:photoViewController animated:YES];
        [photoViewController release];
    }
}

#pragma mark Bulk operations

-(void)deleteSelectedPhotoOnCurrentPage:(Page *)currentPage {
    
    NSFileManager* fileManager = [NSFileManager defaultManager];	
    NSString *applicationDocumentDirPath = [(PhotoAlbumsAppDelegate *)[[UIApplication sharedApplication] delegate] applicationDocumentsDirectory];
    NSString *imagePath = [NSString stringWithFormat:@"%@/%@",applicationDocumentDirPath, currentPage.imagePath];
    NSString *tnImagePath = [NSString stringWithFormat:@"%@/%@.thumbnail",applicationDocumentDirPath, currentPage.imagePath];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:imagePath]) 
    {
        [fileManager removeItemAtPath:imagePath error:nil];
    }
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:tnImagePath]) 
    {
        [fileManager removeItemAtPath:tnImagePath error:nil];
    }
    
    
    [currentPage setValue:nil forKey:@"imagePath"];
    
    [self.album removePagesObject:currentPage];
    [[self applicationManagedObjectContext] deleteObject:currentPage];
    
    [self saveAlbum];
    [self validate];
}


-(void)deleteSelectedPhotos:(id)sender {
    for(Page *page in selectedPagesWhileDoingBulkOperations) {
        [self deleteSelectedPhotoOnCurrentPage:page];
    }
    [selectedPagesWhileDoingBulkOperations removeAllObjects];
    [deleteButton setTitle:@"Delete"];
}

-(void)sharePhotos:(id)sender {

}

-(void)exitFromBulkOperations:(id)sender {
    isDeleteModeActive = NO;
    
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editAlbum)];
    self.navigationItem.rightBarButtonItem = editButton;
    [editButton release];
    
    [self.toolbar setItems:existingToolbarItems];
    [existingToolbarItems release];
}

-(void)manageToolbar {
    existingToolbarItems = [[self.toolbar items] retain];
    
    deleteButton = [[UIBarButtonItem alloc] initWithTitle:@"Delete" style:UIBarButtonItemStyleDone target:self action:@selector(deleteSelectedPhotos:)];
    
    deleteButton.tintColor = [UIColor redColor];
    
    UIBarButtonItem *shareButton = [[UIBarButtonItem alloc] initWithTitle:@"Share" style:UIBarButtonItemStyleDone target:self action:@selector(sharePhotos:)];
    
    deleteButton.width = shareButton.width = self.view.frame.size.width/2 - 10;
    
    [self.toolbar setItems:[NSArray arrayWithObjects:deleteButton, shareButton, nil]];
}

-(IBAction)handleBulkOperations:(id)sender {
    isDeleteModeActive = YES;    
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(exitFromBulkOperations:)];
    cancelButton.tintColor = [UIColor blueColor];
    self.navigationItem.rightBarButtonItem = cancelButton;
    
    [self manageToolbar];
}

@end
