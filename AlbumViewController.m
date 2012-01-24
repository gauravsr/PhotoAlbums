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
	//NSString *documentsDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]; 
	NSString *audioDirectoryPath = [NSString stringWithFormat:@"%@/audio", /*VJ - documentsDirectoryPath,*/album.albumID];
	
	
	return audioDirectoryPath;
}

/**
 Returns the path to the application's Documents directory.
 */
- (NSString *) albumPhotoDirectoryPath 
{
	//NSString *documentsDirectoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]; 
	NSString *photoDirectoryPath = [NSString stringWithFormat:@"%@/photo", /*VJ - documentsDirectoryPath,*/ album.albumID];
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
 *					Getter Setter				*
 ***********************************************/

//- (PhotoViewController *) photoViewController
//{
//	if(photoViewController == nil)
//	{
//		photoViewController = [[PhotoViewController alloc] init];
//		
//		photoViewController.album = self.album;
//		NSString *applicationDocumentDirPath = [(PhotoAlbumsAppDelegate *)[[UIApplication sharedApplication] delegate] applicationDocumentsDirectory];
//		NSString *imageDirectoryPath = 	[NSString stringWithFormat:@"%@/%@",applicationDocumentDirPath, [self albumPhotoDirectoryPath]];
//		NSString *audioDirectoryPath = [NSString stringWithFormat:@"%@/%@",applicationDocumentDirPath, [self albumAudioDirectoryPath]];
//		[self createDirectoryAtpath:imageDirectoryPath];
//		[self createDirectoryAtpath:audioDirectoryPath];
//		photoViewController.albumAudioDirectoryPath = imageDirectoryPath;
//		photoViewController.albumPhotoDirectoryPath = audioDirectoryPath;
//		
//		photoViewController.applicationManagedObjectContext = [self applicationManagedObjectContext];		
//	}
//	
//	return photoViewController;
//}

/************************************************
 *					View Operations				*
 ***********************************************/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
    [super viewDidLoad];
	[mThreadQueue release];
	mThreadQueue = [[NSMutableArray alloc] init];
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editAlbum)];
    self.navigationItem.rightBarButtonItem = editButton;
    [editButton release];
	self.albumThumbnailView.eventDelegate = self;
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
	NSLog(@"Album View Controller Dealloc");
	[mThreadQueue release];
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

- (void)writeFiles: (NSArray *)threadArgs{
	NSAutoreleasePool *aPool = [NSAutoreleasePool new];
	UIImage *image = [threadArgs objectAtIndex:0];
	NSString *imageThumbnailPath = [threadArgs objectAtIndex:1];
	NSString *imagePath = [threadArgs objectAtIndex: 2];
	NSString *localImageThumbnailPath = [threadArgs objectAtIndex:3];
	
	UIImage *thumbnailImage = [PhotoUtil createThumbnail:image];	
	NSData *thumbnailData = [NSData dataWithData:UIImagePNGRepresentation(thumbnailImage)];	
	BOOL thumbnailWriteSuccessFul = [thumbnailData writeToFile:imageThumbnailPath atomically:NO];
	
	if(thumbnailWriteSuccessFul)
	{
		[[PhotoRepository instance] addPhoto:thumbnailImage withPhotoID:localImageThumbnailPath];
	}
	
	NSData *imageData = [NSData dataWithData:UIImagePNGRepresentation(image)];
	//BOOL writeSuccessFul = [imageData writeToFile:imagePath atomically:NO];
	[imageData writeToFile:imagePath atomically:NO];
	[aPool release];
}


- (void) addPageForImage: (UIImage *)image
{
	NSManagedObjectContext *context = [self applicationManagedObjectContext];
	Page *newPage = [NSEntityDescription insertNewObjectForEntityForName:@"Page" inManagedObjectContext:context];
	
	//configure the new managed object.
	[newPage setValue:self.album forKey:@"album"];
	[newPage setValue:[NSDate date] forKey:@"creationDate"];	
	//[self saveAlbum];
	
	NSString *applicationDocumentDirPath = [(PhotoAlbumsAppDelegate *)[[UIApplication sharedApplication] delegate] applicationDocumentsDirectory];
	NSLog(@"Page Id = %@", [newPage pageID]);
	NSString *localImagePath = [NSString stringWithFormat:@"%@/%@",[self albumPhotoDirectoryPath], [newPage pageID]];
	NSString *imageDirectoryPath = 	[NSString stringWithFormat:@"%@/%@",applicationDocumentDirPath, [self albumPhotoDirectoryPath]];
	NSString *imagePath = [NSString stringWithFormat:@"%@/%@",applicationDocumentDirPath, localImagePath];
	NSString *localImageThumbnailPath = [NSString stringWithFormat:@"%@/%@.thumbnail",[self albumPhotoDirectoryPath], [newPage pageID]];
	NSString *imageThumbnailPath = [NSString stringWithFormat:@"%@/%@",applicationDocumentDirPath, localImageThumbnailPath];

	[self createDirectoryAtpath: imageDirectoryPath];
	
	NSArray *threadArgs = [NSArray arrayWithObjects:image, imageThumbnailPath, imagePath, localImageThumbnailPath, nil];
	
	[NSThread detachNewThreadSelector:@selector(writeFiles:) toTarget:self withObject:threadArgs];
	
//	UIImage *thumbnailImage = [PhotoUtil createThumbnail:image];	
//	NSData *thumbnailData = [NSData dataWithData:UIImagePNGRepresentation(thumbnailImage)];	
//	BOOL thumbnailWriteSuccessFul = [thumbnailData writeToFile:imageThumbnailPath atomically:NO];
//	
//	NSData *imageData = [NSData dataWithData:UIImagePNGRepresentation(image)];
//	BOOL writeSuccessFul = [imageData writeToFile:imagePath atomically:NO];
	
	
	
	if(1)
	{
		//add page to album
		[self.album addPagesObject:newPage];
		[newPage setValue:localImagePath forKey:@"imagePath"];
		[newPage setValue:localImageThumbnailPath forKey:@"imageThumbnailPath"];
		
		[[PhotoRepository instance] addPhoto:image withPhotoID:localImagePath];
		
		
		//[self saveAlbum];
	}
	
	//[self validate];
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
	NSLog(@"add Photo:");
	
	if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
	{
		UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
		imagePicker.delegate = self;
		imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
		imagePicker.allowsEditing = NO;
		[mThreadQueue removeAllObjects];
		[self presentModalViewController:imagePicker animated:YES];
		
		[imagePicker release];
		

		
	}
}

- (void) imagePickerController: (UIImagePickerController *)imagePicker didFinishPickingImage:(UIImage *) image
				   editingInfo: (NSDictionary *) editingInfo
{
	UIImage *selectedImage = [[UIImage alloc] initWithCGImage:image.CGImage];
	[mThreadQueue addObject: selectedImage];
	//[self addPageForImage:selectedImage];

	[selectedImage release];
}

- (void) imagePickerControllerDidCancel: (UIImagePickerController *) imagePicker
{
	unsigned i = 0;
	for (; i < [mThreadQueue count]; i++) {
		UIImage *anImage = [mThreadQueue objectAtIndex: i];
		[self addPageForImage: anImage];
	}
	[self saveAlbum];
	[self validate];
	
	[imagePicker dismissModalViewControllerAnimated:YES];
}

/************************************************
 *					SlideShow Operations		*
 ***********************************************/

- (IBAction) startSlideShow: (id) sender
{
	//[self.navigationController pushViewController:self.photoViewController animated:YES];	
}

- (void)thumbnailViewDidSelected: (AlbumThumbnailView *)thumbnailView atIndex: (int)index{
	
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
	aViewController.selectedIndex = index;
	
	[self.navigationController pushViewController:aViewController animated:YES];
	[aViewController release];
}


@end