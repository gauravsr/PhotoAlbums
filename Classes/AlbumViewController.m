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
		/*
		 Replace this implementation with code to handle the error appropriately.
		 
		 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
		 */
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
    }	
}

//- (void)writeFiles: (NSArray *)threadQueue{
//	NSAutoreleasePool *aPool = [NSAutoreleasePool new];
//	unsigned i = 0;
//	
//	for (; i < [threadQueue count]; i++) {
//		NSArray *threadArgs = [threadQueue objectAtIndex: i];
//		UIImage *image = [threadArgs objectAtIndex:0];
//		NSString *imageThumbnailPath = [threadArgs objectAtIndex:1];
//		NSString *imagePath = [threadArgs objectAtIndex: 2];
//		NSString *localImageThumbnailPath = [threadArgs objectAtIndex:3];
//		
//		UIImage *thumbnailImage = [PhotoUtil createThumbnail:image];	
//		NSData *thumbnailData = [NSData dataWithData:UIImagePNGRepresentation(thumbnailImage)];	
//		BOOL thumbnailWriteSuccessFul = [thumbnailData writeToFile:imageThumbnailPath atomically:NO];
//		
//		if(thumbnailWriteSuccessFul)
//		{
//			[[PhotoRepository instance] addPhoto:thumbnailImage withPhotoID:localImageThumbnailPath];
//		}else {
//			NSLog(@"Thumbnail Write Failed");
//		}
//		
//		
//		NSData *imageData = [NSData dataWithData:UIImagePNGRepresentation(image)];
//		BOOL writeSuccessFul = [imageData writeToFile:imagePath atomically:NO];
//		if(writeSuccessFul)
//			NSLog(@"Write Passed.");
//		else 
//			NSLog(@"Write Failed.");
//	
//		//[NSThread sleepForTimeInterval:1];
//	}
//	
//	[self performSelectorOnMainThread:@selector(fileWriteThreadDidEndExecution:) withObject:nil waitUntilDone:YES];
//	
//	[aPool release];
//}


- (void) addPageForImage: (UIImage *)image
{
	NSManagedObjectContext *context = [self applicationManagedObjectContext];
	Page *newPage = [NSEntityDescription insertNewObjectForEntityForName:@"Page" inManagedObjectContext:context];
	
	//configure the new managed object.
	[newPage setValue:self.album forKey:@"album"];
	[newPage setValue:[NSDate date] forKey:@"creationDate"];	
	//[self saveAlbum];
	
	UIImage *scaledImage = [PhotoUtil createSnapshot:image];
	image = scaledImage;
	NSString *applicationDocumentDirPath = [(PhotoAlbumsAppDelegate *)[[UIApplication sharedApplication] delegate] applicationDocumentsDirectory];
	NSString *localImagePath = [NSString stringWithFormat:@"%@/%@",[self albumPhotoDirectoryPath], [newPage pageID]];
	NSString *imageDirectoryPath = 	[NSString stringWithFormat:@"%@/%@",applicationDocumentDirPath, [self albumPhotoDirectoryPath]];
	NSString *imagePath = [NSString stringWithFormat:@"%@/%@",applicationDocumentDirPath, localImagePath];
	NSString *localImageThumbnailPath = [NSString stringWithFormat:@"%@/%@.thumbnail",[self albumPhotoDirectoryPath], [newPage pageID]];
	NSString *imageThumbnailPath = [NSString stringWithFormat:@"%@/%@",applicationDocumentDirPath, localImageThumbnailPath];

	[self createDirectoryAtpath: imageDirectoryPath];
	
	//NSArray *threadArgs = [NSArray arrayWithObjects:image, imageThumbnailPath, imagePath, localImageThumbnailPath, nil];
	//[mThreadQueue addObject: threadArgs];
	
	//[NSThread detachNewThreadSelector:@selector(writeFiles:) toTarget:self withObject:threadArgs];
	
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
		
	//	[self saveAlbum];
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

/************************************************
 *					Add Photo Operations		*
 ***********************************************/

- (IBAction) addPhoto: (id) sender
{
	//[mThreadQueue removeAllObjects];
//	if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
//	{
//		UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
//		imagePicker.delegate = self;
//		imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
//		imagePicker.allowsEditing = NO;
//		mPhotoSourceType = UIImagePickerControllerSourceTypePhotoLibrary;
//		[self presentModalViewController:imagePicker animated:YES];
//		
//		[imagePicker release];
//	}
    
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

#pragma mark Action Sheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
	if(buttonIndex == 0){
        [self addPhotoFromCamera];
	}
	else if(buttonIndex == 1){

        ELCAlbumPickerController *albumController = [[ELCAlbumPickerController alloc] init];
        ELCImagePickerController *elcPicker = [[ELCImagePickerController alloc] initWithRootViewController:albumController];
        
        [albumController setParent:elcPicker];
        [elcPicker setDelegate:self];
        
        [self presentModalViewController:elcPicker animated:YES];
        [elcPicker release];
        [albumController release];
	}
}

#pragma mark ELCImagePickerControllerDelegate Methods

- (void)elcImagePickerController:(ELCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info {
	
	[self dismissModalViewControllerAnimated:YES];
	
    for (UIView *v in [scrollview subviews]) {
        [v removeFromSuperview];
    }
    
	//CGRect workingFrame = scrollview.frame;
	//workingFrame.origin.x = 0;
    
	for(NSDictionary *dict in info) {
        
        //UIImage *image = [dict objectForKey:UIImagePickerControllerOriginalImage];
		//UIImageView *imageview = [[UIImageView alloc] initWithImage:image];
		//[imageview setContentMode:UIViewContentModeScaleAspectFit];
		//imageview.frame = workingFrame;
		
		//[scrollview addSubview:imageview];
        //workingFrame.origin.x = workingFrame.origin.x + workingFrame.size.width;
        
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
    
    
	//[scrollview setPagingEnabled:YES];
	//[scrollview setContentSize:CGSizeMake(workingFrame.origin.x, workingFrame.size.height)];

    
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
	//[NSThread detachNewThreadSelector:@selector(writeFiles:) toTarget:self withObject:mThreadQueue];
}

- (void) addPhotoFromCamera {
    //UIImagePickerControllerMediaMetadata
    
	//[mThreadQueue removeAllObjects];
	if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
	{
		UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
		//imagePicker.delegate = self;
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



- (void)thumbnailViewDidSelectedIndex: (int)index {
	PhotoViewController *aViewController = [self preparePhotoViewController];
    aViewController.selectedIndex = index;
	
	[self.navigationController pushViewController:aViewController animated:YES];
	[aViewController release];
}

@end