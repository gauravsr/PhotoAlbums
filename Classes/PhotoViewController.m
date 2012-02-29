//
//  PhotoViewController.m
//  PhotoBook
//
//  Created by raheja on 04/06/10.
//  Copyright Xebia IT Architects India Private Limited 2010. All rights reserved.
//

#import "PhotoViewController.h"
#import "PageView.h"
#import "PhotoAlbumsAppDelegate.h"
#import "ScrollViewForPageView.h"

@interface NSObject (AnimationPrivateAPIAccess)

- (void)setAnimationPosition: (CGPoint)point;

@end

@implementation NSObject (AnimationPrivateAPIAccess)

- (void)setAnimationPosition: (CGPoint)point
{
    
}
@end

#pragma mark -
#pragma mark OS Callback

void interruptionListenerCallback ( void	*inUserData, UInt32	interruptionState) 
{
	// This callback, being outside the implementation block, needs a reference 
	//	to the AudioViewController object
	PhotoViewController *controller = (PhotoViewController *) inUserData;
	
	if (interruptionState == kAudioSessionBeginInterruption) 
	{
		NSLog (@"Interrupted. Stopping playback or recording.");
		
		if (controller.audioRecorder) 
		{
			// if currently recording, stop
			[controller saveRecordedAudioNote:(id) controller];
		} 
		else if (controller.audioPlayer) 
		{
			// if currently playing, pause
			[controller pauseAudioNotePlayback:(id) controller];
			controller.interruptedOnPlayback = YES;
		}
	} 
	else if ((interruptionState == kAudioSessionEndInterruption) && controller.interruptedOnPlayback) 
	{
		// if the interruption was removed, and the app had been playing, resume playback
		[controller resumeAudioNotePlayback:(id) controller];
		controller.interruptedOnPlayback = NO;
	}
}

#pragma mark -
@implementation PhotoViewController

//model
@synthesize album, albumAudioDirectoryPath, albumPhotoDirectoryPath;
@synthesize applicationManagedObjectContext;
@synthesize currentPageIndex, interruptedOnPlayback, slideshowMode;
@synthesize selectedIndex;
@synthesize previousSlideEndTime;
@synthesize tagsView;
@synthesize textFieldForEnteringTag;
@synthesize scrollViewForShowingAndDeletingTags;
@synthesize fetchedTagsFromCoredata;
@synthesize albumOfTypeTag;
@synthesize tableViewForShowingAvailableTags;
//view
@synthesize albumView, pageViewCollection, pageToolBar;
@synthesize matchingTags;
//utils
@synthesize audioRecorder, audioPlayer, recordingTimer, slideShowTimer;


#pragma mark -
#pragma mark Core Data
- (void) saveAlbum 
{
	// Save the context.
    NSError *error = nil;
    if (![[self applicationManagedObjectContext] save:&error]) 
    {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }	
}

-(CGRect)frameForScrollViewForZooming:(int)index {
    CGRect bounds = self.albumView.bounds;
    CGRect pageFrame = bounds;
    pageFrame.size.width -= 20;
    pageFrame.origin.x = (bounds.size.width * index) + 10;
    return pageFrame;
}

- (void) validateAlbum 
{
	unsigned pageViewCount = [self.pageViewCollection count];
	
	[self.albumView setContentSize:CGSizeMake(self.albumView.frame.size.width * pageViewCount, self.albumView.frame.size.height)];
    [self.albumView setPagingEnabled:YES];
	[self.albumView setContentOffset:CGPointMake(self.albumView.frame.size.width * MAX(0, currentPageIndex), 0)];
    [self.albumView setDelegate:self];
	
	BOOL pageOrderChanged = NO;
    ScrollViewForPageView *scrollViewForPageView;
	Page *page;
	
	for(unsigned i = 0; i < pageViewCount; i++) 
    {
		scrollViewForPageView = (ScrollViewForPageView *)[self.pageViewCollection objectAtIndex:i];
        page = scrollViewForPageView.pageView.page;
		if([page.pageOrder intValue] != i) {
			[page setValue:[NSNumber numberWithInt:i] forKey:@"pageOrder"];
			pageOrderChanged = YES;
		}
		
        [scrollViewForPageView setFrame:[self frameForScrollViewForZooming:i]];
	}	
	
	if(pageOrderChanged) 
    {
		[self saveAlbum];
	}
}

- (void) stopRecording 
{
	[self.audioRecorder setStopping: YES];				// this flag lets the property listener callback
	
	[self.audioRecorder stop];							// stops the recording audio queue object. the object 
	
	//	remains in existence until it actually stops, at
	//	which point the property listener callback calls
	//	this class's updateUserInterfaceOnAudioQueueStateChange:
	//	method, which releases the recording object.
	// now that recording has stopped, deactivate the audio session
	AudioSessionSetActive (false);		
}

/************************************************
 *					Album Operations			*
 ***********************************************/

- (UIImage *)imageForIndex: (int)index {
	ScrollViewForPageView *scrollViewForPageView = [self.pageViewCollection objectAtIndex:currentPageIndex];
    UIImage *anImage = scrollViewForPageView.pageView.image;
	return anImage;
}

- (void) addPageViewForPage: (Page *)page 
				  withImage: (UIImage *)image 
					atIndex: (int)index 
{
    ScrollViewForPageView *scrollViewForPageView;
    scrollViewForPageView = [self.pageViewCollection objectAtIndex:index];
	if([scrollViewForPageView.pageView isLoaded]){
		[self validateAlbum];
		return;
	}
	
	// Otherwise load image inside the view
	if(image == nil)
	{
		NSString *applicationDocumentDirPath = [(PhotoAlbumsAppDelegate *)[[UIApplication sharedApplication] delegate] applicationDocumentsDirectory];
		NSString *imagePath = [NSString stringWithFormat:@"%@/%@",applicationDocumentDirPath, page.imagePath];
		
		if ([[NSFileManager defaultManager] fileExistsAtPath:imagePath]) 
		{
			UIImage *pageViewImage = [[UIImage alloc] initWithContentsOfFile:imagePath];		
			scrollViewForPageView = [[[ScrollViewForPageView alloc]init] addImage:pageViewImage];
            [scrollViewForPageView.pageView setIsLoaded:YES];			
		}
		else
		{
			NSLog(@"Error!!! no image at specified imagePath");
			scrollViewForPageView = [[ScrollViewForPageView alloc] init];	
			[scrollViewForPageView.pageView setIsLoaded:NO];
		}		
	}
	else
	{
		scrollViewForPageView = [[ScrollViewForPageView alloc] addImage:image];		
	}
    [scrollViewForPageView.pageView setPage:page];	
    [pageViewCollection replaceObjectAtIndex:index withObject:scrollViewForPageView];
    
    [albumView addSubview:scrollViewForPageView];
	
	[self validateAlbum];	
	[scrollViewForPageView release];
}

- (void)populatePageForSelectedIndex: (int)aSelectedIndex
{
	NSArray *pageViews = [self.pageViewCollection valueForKey:@"pageView"];
    NSArray *pages = [pageViews valueForKey:@"page"];

	unsigned totalPages = [pages count];
	int startIndex = 0; // Initialize
	int endIndex = 0; // Initialize
	if(aSelectedIndex > 0)
    {
		startIndex = aSelectedIndex - 1;
		endIndex = aSelectedIndex + 1;
	} else
    {
		startIndex = 0;
		endIndex = aSelectedIndex + 1;
	}
	
	if(endIndex >= totalPages)
		endIndex = totalPages - 1;
	
	int i = startIndex;
	for(; i <= endIndex; i++)
    {
		Page *page = [pages objectAtIndex:i];
		[self addPageViewForPage:page withImage:nil atIndex: i];
	}	
}

- (void) populateAlbum
{
	[self.pageViewCollection removeAllObjects];
	NSArray *pages = [self.album.pages allObjects];
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"creationDate" ascending:YES];
	pages = [pages sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
	[sortDescriptor release];
	
	unsigned pageCount = [pages count];
	
	Page *page;
	for(unsigned i = 0; i < pageCount; i++)
	{
		page = [pages objectAtIndex:i];
		PageView *aPageView = [[PageView alloc] init];
		aPageView.page = page;
        [aPageView setIsLoaded:NO];
        
        ScrollViewForPageView *scrollViewForPageView = [[ScrollViewForPageView alloc] init];
        scrollViewForPageView.pageView = aPageView;
        [self.pageViewCollection addObject:scrollViewForPageView];
	}
	
	if(pageCount == 0)
	{
		self.currentPageIndex = -1;
	} else
		self.currentPageIndex = self.selectedIndex;
	
	[self validate];
}

- (NSInteger)currentIndex 
{
	NSUInteger pageWidth = albumView.frame.size.width;	
	NSUInteger pageIndex = floor((albumView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
	return pageIndex;
}

#pragma mark -
#pragma mark View Lifecycle

- (void) viewDidLoad 
{
    [super viewDidLoad];
	
	pageViewCollection = [[NSMutableArray alloc] init];
	
	// initialize the audio session object for this application,
	// registering the callback that Audio Session Services will invoke 
	// when there's an interruption
	AudioSessionInitialize (
							NULL,
							NULL,
							interruptionListenerCallback,
							self
							);
}

- (void) viewWillAppear: (BOOL) animated
{
	[super viewWillAppear: animated];
    
    self.matchingTags = [[NSMutableArray alloc] init];
    
	self.currentPageIndex = -1;		
	[self populateAlbum];
	[self populatePageForSelectedIndex:self.selectedIndex];
	self.currentPageIndex = self.selectedIndex;
    
    if(self.slideshowMode == YES) 
    {
        [self startSlideShow];
    } else 
    {
        [self.pageToolBar setHidden:NO];
        [self.navigationController setNavigationBarHidden:NO];
    }
    [self playAudioNote:(id) self];
}

- (void) viewWillDisappear: (BOOL)animated
{
	[super viewWillDisappear: animated];
	if(self.audioPlayer != nil)
	{
		[self stopAudioNotePlayback:self];
	}
	
	if(self.audioRecorder != nil)
	{
		[self stopRecording];		
	}
	
}


 // Override to allow orientations other than the default portrait orientation. 
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation  
{
    // Return YES for supported orientations
    return NO;
}

- (void) didReceiveMemoryWarning 
{
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	NSLog(@"didReceiveMemoryWarning");
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload 
{
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

#pragma mark -
#pragma mark View State
- (BOOL) isValidState
{
	if(self.currentPageIndex >= 0 && self.currentPageIndex < [self.pageViewCollection count])
	{
		return YES;
	} else
	{
		return NO;
	}
}

- (void) refreshTitle
{
	if([self isValidState])
	{
		self.title = [NSString stringWithFormat:@"%d of %d",currentPageIndex + 1,[self.pageViewCollection count]];		
	} else
	{
		self.title = @"";
	}
}

- (void) validatePageToolBar
{
	if([self isValidState])
	{
		if(self.audioPlayer)
		{
			[self.pageToolBar showPlayAudioNoteToolBar];
		} else if(self.audioRecorder)
		{
			[self.pageToolBar showRecordAudioNoteToolBar];
		} else
		{
            ScrollViewForPageView *scrollViewForPageView = [self.pageViewCollection objectAtIndex:self.currentPageIndex];
            [self.pageToolBar setAudioAvailable:[scrollViewForPageView.pageView.page hasAudioNote]];
            [self.pageToolBar setAudioAvailable:[scrollViewForPageView.pageView.page hasAudioNote]];
			[self.pageToolBar showDefaultToolBar];
		}
	} else
	{
		[self.pageToolBar setAudioAvailable:NO];	
		[self.pageToolBar showDefaultToolBar];
	}
}


- (void) validate
{
	[self validateAlbum];
	[self validatePageToolBar];
	[self refreshTitle];    
}



#pragma mark Tag

#define SCROLL_VIEW_HEIGHT 40
#define TAG_WIDTH 100
#define TAG_HEIGHT 20

-(CGRect)frameForTagsView {
    CGSize viewSize = [self.view bounds].size;
    CGRect frame = CGRectMake(currentPageIndex * viewSize.width, 
                              viewSize.height/2 - 60, 
                              viewSize.width, 
                              395);
    return frame;
}

-(CGRect)frameForShowingAndDeletingTags {
    CGRect frame = [[UIScreen mainScreen] bounds];
    frame.size.height = 30;
    return frame;
}

-(CGSize)contentSizeForTagScrollView:(int)index {
    return CGSizeMake((TAG_WIDTH +20) * index, 0);
}

-(CGRect)frameForTextFieldForEnteringTag {
    CGRect mainScreenFrame = [[UIScreen mainScreen] bounds];
    return CGRectMake(20, 55, mainScreenFrame.size.width/2, 20);
}

-(void)scrollViewForPageViewTapped:(id)sender {
    [tagsView removeFromSuperview];
    [tableViewForShowingAvailableTags removeFromSuperview];
}

-(NSMutableArray *)listOfAlbumLabelsOfTypeTag {
    NSMutableArray *list = [[NSMutableArray alloc] init];
    NSError *error;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Album" 
                                              inManagedObjectContext:applicationManagedObjectContext];
    [fetchRequest setEntity:entity];
    fetchedTagsFromCoredata = [[applicationManagedObjectContext executeFetchRequest:fetchRequest error:&error] retain];
    
    ScrollViewForPageView *scrollViewForPageView = [self.pageViewCollection objectAtIndex:currentPageIndex];
    Page *currentPage = scrollViewForPageView.pageView.page;   
    
    for(Album *albumsOfTypeTag in fetchedTagsFromCoredata) {
        if(albumsOfTypeTag.isTag == [NSNumber numberWithInt:1]) {
            for(Page *page in albumsOfTypeTag.pages) {
                if([page isEqual:currentPage]) {
                    [list addObject:albumsOfTypeTag.title];
                }
            }
        }
        
    }
    
    [fetchRequest release];
    
    
    return list;
}

-(NSMutableArray *)listOfTagsAvailableInAllAlbums {
    NSMutableArray *list = [[NSMutableArray alloc] init];
    NSError *error;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Album" 
                                                        inManagedObjectContext:applicationManagedObjectContext];
    [fetchRequest setEntity:entity];
    NSArray *result = [[applicationManagedObjectContext executeFetchRequest:fetchRequest error:&error] retain];
         
    for(Album *albumObject in result) {
        if(albumObject.isTag == [NSNumber numberWithInt:1]) {
            [list addObject:albumObject.title];
        }
    }
    
    [fetchRequest release];
    
    
    return list;
}

-(void)deleteTag:(id)sender {
    UILabel *selectedTag = (UILabel *)[sender view];
    [selectedTag removeFromSuperview];
    
    ScrollViewForPageView *scrollViewForPageView = [self.pageViewCollection objectAtIndex:currentPageIndex];
    Page *currentPage = scrollViewForPageView.pageView.page;
    
    NSError *error;
    for(Album *albumObject in self.fetchedTagsFromCoredata) {
        if([albumObject.isTag isEqualToNumber:[NSNumber numberWithInt:1]]) {
            for(Page *page in albumObject.pages) {
                if([currentPage isEqual:page]) {
                    if(selectedTag.text == albumObject.title) {
                        [albumObject removePagesObject:currentPage];
                        if (![applicationManagedObjectContext save:&error]) {
                            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                            abort();
                        }
                        break;
                    }
                }
            }
        }
    }
}

-(void)showTags {
    NSMutableArray *list = [self listOfAlbumLabelsOfTypeTag];
    
    for(int i=0; i<[list count]; i++) {
        CGRect frameForUILabel = CGRectMake(i * (TAG_WIDTH + 20), 5, TAG_WIDTH, TAG_HEIGHT);
        UILabel *label = [[UILabel alloc] initWithFrame:frameForUILabel];
        label.text = [list objectAtIndex:i];
        label.userInteractionEnabled = YES;
        UILongPressGestureRecognizer *longPressGesture = [[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(deleteTag:)] autorelease];
        [label addGestureRecognizer:longPressGesture];
        [scrollViewForShowingAndDeletingTags addSubview:label];
        scrollViewForShowingAndDeletingTags.contentSize = [self contentSizeForTagScrollView:i];        
    }
}

-(NSMutableArray *)filterAlbumsOfTypeTag {
    NSMutableArray *list = [[NSMutableArray alloc] init];
    
    for(Album *currentAlbum in self.fetchedTagsFromCoredata) {
        if([currentAlbum.isTag isEqualToNumber:[NSNumber numberWithInt:1]]) {
            [list addObject:currentAlbum];
        }
    }
    
    return list;
}

-(void)addTagHandler:(id)sender {
	NSError *error = nil;
    BOOL isTagAlreadyPresent = NO;
    Album *tempAlbumObject;
    ScrollViewForPageView *scrollViewForPageView = [self.pageViewCollection objectAtIndex:currentPageIndex];
    Page *page = scrollViewForPageView.pageView.page;
    
    NSMutableArray *listOfAlbumsOfTypeTag = [self filterAlbumsOfTypeTag];
    
    if([listOfAlbumsOfTypeTag count] == 0) {
        albumOfTypeTag = [NSEntityDescription insertNewObjectForEntityForName:@"Album" 
                                                       inManagedObjectContext:applicationManagedObjectContext];
        [albumOfTypeTag setValue:[textFieldForEnteringTag text] forKey:@"title"];
        [albumOfTypeTag addPagesObject:page];
        [albumOfTypeTag setValue:[NSDate date] forKey:@"creationDate"];
        [albumOfTypeTag setValue:[NSNumber numberWithBool:1] forKey:@"isTag"];
        
        if (![applicationManagedObjectContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
    else {
        for(Album *currentAlbum in listOfAlbumsOfTypeTag) {
            if([[currentAlbum valueForKey:@"title"] isEqualToString:[textFieldForEnteringTag text]]) {
                isTagAlreadyPresent = YES;
                tempAlbumObject = currentAlbum;
                break;
                
            }
            else {
                isTagAlreadyPresent = NO;
            }
        }
        if(isTagAlreadyPresent) {
            [tempAlbumObject addPagesObject:page];
            if (![applicationManagedObjectContext save:&error]) {
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                abort();
            }
        }
        else {
            albumOfTypeTag = [NSEntityDescription insertNewObjectForEntityForName:@"Album" 
                                                           inManagedObjectContext:applicationManagedObjectContext];
            [albumOfTypeTag setValue:[textFieldForEnteringTag text] forKey:@"title"];
            [albumOfTypeTag addPagesObject:page];
            [albumOfTypeTag setValue:[NSDate date] forKey:@"creationDate"];
            [albumOfTypeTag setValue:[NSNumber numberWithBool:1] forKey:@"isTag"];
            
            if (![applicationManagedObjectContext save:&error]) {
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                abort();
            }
        }
    }
    
    [self showTags];
}

-(void)addScrollViewForShowingAndDeletingTags {
    scrollViewForShowingAndDeletingTags = [[UIScrollView alloc] initWithFrame:[self frameForShowingAndDeletingTags]];
    
    scrollViewForShowingAndDeletingTags.backgroundColor = [UIColor lightGrayColor];
    [tagsView addSubview:scrollViewForShowingAndDeletingTags];
}

-(void)addTextFieldForTag {
    textFieldForEnteringTag = [[UITextField alloc] initWithFrame:[self frameForTextFieldForEnteringTag]];
    textFieldForEnteringTag.placeholder = @"Enter a tag";
    textFieldForEnteringTag.delegate = self;
    textFieldForEnteringTag.backgroundColor = [UIColor purpleColor];    
    [tagsView addSubview:textFieldForEnteringTag];
    [textFieldForEnteringTag becomeFirstResponder];
}

-(void)addTableViewForAutoSuggestingTags {
    CGRect mainScreenFrame = [[UIScreen mainScreen] bounds];
    tableViewForShowingAvailableTags = [[UITableView alloc] 
                                        initWithFrame:CGRectMake(20, 135, mainScreenFrame.size.width/2, 100) 
                                        style:UITableViewStylePlain];
    tableViewForShowingAvailableTags.delegate = self;
    tableViewForShowingAvailableTags.rowHeight = 30;
    tableViewForShowingAvailableTags.dataSource = self;
    tableViewForShowingAvailableTags.userInteractionEnabled = YES;
    tableViewForShowingAvailableTags.scrollEnabled = YES;
    tableViewForShowingAvailableTags.hidden = YES;  
    [self.view addSubview:tableViewForShowingAvailableTags];
}

-(void)showHideTags {
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                            selector:@selector(scrollViewForPageViewTapped:) 
                                            name:@"ScrollViewForPageViewTapped" 
                                            object:nil];
    
    tagsView = [[UIView alloc] initWithFrame:[self frameForTagsView]];
    tagsView.backgroundColor = [UIColor redColor];
    [self.albumView addSubview:tagsView];
    
    [self addScrollViewForShowingAndDeletingTags];
    [self showTags];
    [self addTextFieldForTag];
    [self addTableViewForAutoSuggestingTags];
    
    CGRect frameForAddTagButton = CGRectMake(200, 55, 50 , 20);
    UIButton *addTagButton = [[UIButton alloc] initWithFrame:frameForAddTagButton];
    [addTagButton setTitle:@"Add" forState:UIControlStateNormal];
    [addTagButton setBackgroundColor:[UIColor blackColor]];
    [addTagButton addTarget:self action:@selector(addTagHandler:) forControlEvents:UIControlEventTouchUpInside];
    [tagsView addSubview:addTagButton];
}

-(IBAction)manageTagForThePhoto:(id)sender {    
    [self showHideTags];
}

- (void)searchTagsMatchingString:(NSString *)substring {
    
    [self.matchingTags removeAllObjects];
    for(NSString *curString in [self listOfTagsAvailableInAllAlbums]) {
        NSRange substringRange = [curString rangeOfString:substring];
        if (substringRange.location == 0) {
            [matchingTags addObject:curString];  
        }
    }
    [tableViewForShowingAvailableTags reloadData];
}

#pragma mark - Text Field delegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textFieldForEnteringTag resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    tableViewForShowingAvailableTags.hidden = NO;
    
    NSString *substring = [NSString stringWithString:textFieldForEnteringTag.text];
    substring = [substring stringByReplacingCharactersInRange:range withString:string];
    [self searchTagsMatchingString:substring];
    return YES;
}


#pragma mark Auto complete Tag (UITableViewDataSource methods)

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger) section {
    if(self.matchingTags.count == 0) {
        tableViewForShowingAvailableTags.hidden = YES;
        return 0;
    }
    else {
        return self.matchingTags.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = nil;
    static NSString *CellIdentifier = @"Cell";
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] 
                 initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    cell.textLabel.text = [self.matchingTags objectAtIndex:indexPath.row];
    return cell;
}

#pragma mark Auto complete Tag (UITableViewDelegate methods)

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    textFieldForEnteringTag.text = selectedCell.textLabel.text;
    
    tableViewForShowingAvailableTags.hidden = YES;
    
}


#pragma mark Scroll View delegate

-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    ScrollViewForPageView *scrollViewForPageView = [self.pageViewCollection objectAtIndex:currentPageIndex];
    scrollViewForPageView.zoomScale = 0.5;
}

- (void) scrollViewDidEndDecelerating:(UIScrollView *)sender 
{
	NSInteger pageIndex = [self currentIndex];
	if(currentPageIndex != pageIndex)
	{
		currentPageIndex = pageIndex;
		[self refreshTitle];
		[self populatePageForSelectedIndex:pageIndex];

		if(self.audioRecorder != nil)
		{
			[self saveRecordedAudioNote:self];
		}
		
		if(self.audioPlayer != nil)
		{
			[self stopAudioNotePlayback:self];
		}
        
		[self validatePageToolBar];	
		[pageToolBar showDefaultToolBar];
		
		[self playAudioNote:(id) self];
        self.previousSlideEndTime = [NSDate date];
        
        [tagsView removeFromSuperview];
    }
}

#pragma mark -
#pragma mark Add/Play Audio Note			

- (void) initAudioRecorderWithURL: (NSURL *) fileURL
{	
	if (audioRecorder == nil) 
	{
		// before instantiating the recording audio queue object, 
		//	set the audio session category
		UInt32 sessionCategory = kAudioSessionCategory_RecordAudio;
		AudioSessionSetProperty (
								 kAudioSessionProperty_AudioCategory,
								 sizeof (sessionCategory),
								 &sessionCategory
								 );
		
		// the first step in recording is to instantiate a recording audio queue object
		AudioRecorder *theRecorder = [[AudioRecorder alloc] initWithURL: fileURL];
		
		// if the audio queue was successfully created, initiate recording.
		if (theRecorder) 
		{
			self.audioRecorder = theRecorder;
			[theRecorder release];								// decrements the retain count for the theRecorder object
			
			[self.audioRecorder setNotificationDelegate: self];	// sets up the recorder object to receive property change notifications 
			//	from the recording audio queue object			
		}
	}	
}



/*
 *	ADD AUDIO NOTE
 */
- (IBAction) addAudioNote: (id) sender
{
	
	NSLog(@"addAudioNote:");
	if([self isValidState])
	{
		ScrollViewForPageView *scrollViewForPageView = [self.pageViewCollection objectAtIndex:currentPageIndex];
		Page *currentPage = scrollViewForPageView.pageView.page;
		NSString *audioLocalPath = [(PhotoAlbumsAppDelegate *)[[UIApplication sharedApplication] delegate] relativeAudioPathForAlbumId: self.album.albumID];
		NSString *audioNotePath = [NSString stringWithFormat:@"%@/%@", audioLocalPath, currentPage.pageID];
 		[currentPage setValue:audioNotePath forKey:@"audioNotePath"];
		[self saveAlbum];
		
		[self initAudioRecorderWithURL: currentPage.audioNoteURL];
		
		// activate the audio session immediately before recording starts
		AudioSessionSetActive (true);
		
		//start audio recording
		NSLog (@"sending record message to recorder object.");	
		[self.audioRecorder record];						// starts the recording audio queue object
		
		//TBD: make this toolbar view modal
		[pageToolBar showRecordAudioNoteToolBar];		
	}
}

- (void)deleteAudioNoteExecute: (id)sender{
	NSLog(@"deleteAudioNote:");
	if([self isValidState])
	{
		ScrollViewForPageView *scrollViewForPageView = [self.pageViewCollection objectAtIndex:currentPageIndex];
		Page *currentPage = scrollViewForPageView.pageView.page;
		
		if([currentPage hasAudioNote])
		{
			if(self.audioPlayer)
			{
				[self stopAudioNotePlayback: self];
			}
			
			NSFileManager* fileManager = [NSFileManager defaultManager];	
			NSString *applicationDocumentDirPath = [(PhotoAlbumsAppDelegate *)[[UIApplication sharedApplication] delegate] applicationDocumentsDirectory];
			NSString *imagePath = [NSString stringWithFormat:@"%@/%@",applicationDocumentDirPath, currentPage.audioNotePath];
			if ([[NSFileManager defaultManager] fileExistsAtPath:imagePath]) 
			{
				[fileManager removeItemAtPath:imagePath error:nil];
			}
			[currentPage setValue:nil forKey:@"audioNotePath"];
			[self saveAlbum];
			[currentPage setAudioNoteURL:nil];
			
			[self validatePageToolBar];
		}
		
		[pageToolBar showDefaultToolBar];
	}		
}

-(IBAction) deleteAudioNote: (id) sender;
{
	UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"This will delete the associated voice note from the Application.\n Do you want to continue?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete" otherButtonTitles:nil];
	actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
	[actionSheet showInView:self.view]; 
	[actionSheet release];
}


- (IBAction) saveRecordedAudioNote: (id) sender
{
	if(self.audioRecorder != nil)
	{
		[self stopRecording];		
	}
}

/*
 *	PLAY AUDIO NOTE
 */
- (void) initAudioPlayerWithURL: (NSURL *) fileURL
{
	if (self.audioPlayer == nil) 
	{	
		// before instantiating the playback audio queue object, 
		//	set the audio session category
		UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
		AudioSessionSetProperty (
								 kAudioSessionProperty_AudioCategory,
								 sizeof (sessionCategory),
								 &sessionCategory
								 );
		
		AudioPlayer *thePlayer = [[AudioPlayer alloc] initWithURL: fileURL];
		
		if (thePlayer) 
		{
			self.audioPlayer = thePlayer;
			[thePlayer release];								// decrements the retain count for the thePlayer object
			
			[self.audioPlayer setNotificationDelegate: self];	// sets up the playback object to receive property change notifications from the playback audio queue object
			
		}		
	}	
}

- (IBAction) playAudioNote: (id) sender 
{	
	NSLog (@"playAudioNote:");
	if([self isValidState])
	{
        ScrollViewForPageView *scrollViewForPageView = [self.pageViewCollection objectAtIndex:currentPageIndex];
		Page *currentPage = scrollViewForPageView.pageView.page;
		if([currentPage hasAudioNote])
		{
			[self initAudioPlayerWithURL: currentPage.audioNoteURL];
			
			// activate the audio session immmediately before playback starts
			AudioSessionSetActive (true);
			
			NSLog (@"sending play message to play object.");
			[self.audioPlayer play];
			
			//TBD: make this toolbar view modal
			[pageToolBar showPlayAudioNoteToolBar];						
		}
	}	
}

- (IBAction) pauseAudioNotePlayback: (id) sender
{
	if (self.audioPlayer) 
	{		
		NSLog (@"pauseAudioNotePlayback");
		[self.audioPlayer pause];
		[pageToolBar setAudioPlaybackPauseState];
	}	
}

- (IBAction) resumeAudioNotePlayback: (id) sender
{
	if (self.audioPlayer) 
	{		
		NSLog (@"resumeAudioNotePlayback");
		
		// before resuming playback, set the audio session
		// category and activate it
		UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
		AudioSessionSetProperty (
								 kAudioSessionProperty_AudioCategory,
								 sizeof (sessionCategory),
								 &sessionCategory
								 );
		AudioSessionSetActive (true);
		
		[self.audioPlayer resume];
		[pageToolBar setAudioPlaybackNormalState];
	}	
}

- (IBAction) stopAudioNotePlayback: (id) sender
{
	if (self.audioPlayer) 
	{
		NSLog (@"User tapped Stop to stop playing.");
		[audioPlayer setAudioPlayerShouldStopImmediately: YES];
		
		NSLog (@"Calling AudioQueueStop from controller object.");
		[audioPlayer stop];
		
		// now that playback has stopped, deactivate the audio session
		AudioSessionSetActive (false);		
	}
}

// this method gets called (by property listener callback functions) when a recording or playback 
// audio queue object starts or stops. 
- (void) updateUserInterfaceOnAudioQueueStateChange: (AudioQueueObject *) inQueue 
{	
	NSLog (@"updateUserInterfaceOnAudioQueueStateChange just called.");
	
	
	// the audio queue (playback or record) just started
	if ([inQueue isRunning]) 
	{		
		// playback just started
		if (inQueue == self.audioPlayer) 
		{			
			NSLog (@"playback just started.");
		} 
		else if (inQueue == self.audioRecorder) 
		{			
			NSLog (@"recording just started.");
		}
	}	
	// the audio queue (playback or record) just stopped
	else 
	{
		// playback just stopped
		if (inQueue == self.audioPlayer) 
		{
			NSLog (@"playback just stopped.");
			
			[audioPlayer release];
			audioPlayer = nil;
		}	
		// recording just stopped
		else if (inQueue == self.audioRecorder) 
		{
			NSLog (@"recording just stopped.");
			[audioRecorder release];
			audioRecorder = nil;
		}		
		
		[pageToolBar showDefaultToolBar];
		[self validatePageToolBar]; 
	}
}

#pragma mark -
#pragma mark Slideshow

- (void)startSlideShow
{
    [self.pageToolBar setHidden:YES];
    [self.navigationController setNavigationBarHidden:YES];

    self.previousSlideEndTime = [NSDate date];
    slideShowTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(slideShowTimerCallback:) userInfo:nil repeats:YES];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(slideShowTimer != nil && [slideShowTimer isValid])
    {
        [self stopSlideShow];
    }
}

- (void)stopSlideShow
{
    if(self.audioPlayer != nil)
    {
        [self stopAudioNotePlayback:self];
    }
    
    self.slideshowMode = NO;
    
    [self.pageToolBar setHidden:NO];
    [self.navigationController setNavigationBarHidden:NO];
    [slideShowTimer invalidate];
}

- (void)slideShowTimerCallback: (NSTimer *)aTimer{
	int aCurrentPhotoIndex = [self currentPageIndex];
    
    if(self.audioPlayer == nil) 
    {
        NSDate *currentDate = [NSDate date];
        NSTimeInterval interval = 4.0;
        if(self.previousSlideEndTime != nil)
        {
            interval = [currentDate timeIntervalSinceDate:self.previousSlideEndTime];
        }
        
        if(aCurrentPhotoIndex == [album.pages count] - 1)
        {
            [self stopSlideShow];
        } else if(interval > kSlideShowTimeInterval)
        {
            self.previousSlideEndTime = currentDate;
            
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:0.5];
            [self.albumView setContentOffset:CGPointMake(self.albumView.frame.size.width * MAX(0, ++aCurrentPhotoIndex), 0)];
            currentPageIndex = aCurrentPhotoIndex-1;
            [UIView commitAnimations];
            
            NSLog(@"Current index = %d Photo Index = %d", currentPageIndex, aCurrentPhotoIndex);
            
            [self validatePageToolBar];	
            [self refreshTitle];
            
            [self populatePageForSelectedIndex:[self currentPageIndex]];
            [self playAudioNote:(id) self];
        }        
    }
}
 

#pragma mark -
#pragma mark Other Actions

- (IBAction) deletePageExecute: (id) sender
{
	NSLog(@"deletePage");
	if(currentPageIndex >= 0 && currentPageIndex < [pageViewCollection count])
	{
        ScrollViewForPageView *scrollViewForPageView = [self.pageViewCollection objectAtIndex:currentPageIndex];
		Page *currentPage = scrollViewForPageView.pageView.page;
		
		//remove pageView
		[UIView beginAnimations:@"suck" context:NULL];
		[UIView setAnimationTransition:103 forView:albumView cache:YES];
		[UIView setAnimationDuration:1.2];
		if([UIView respondsToSelector:@selector(setAnimationPosition:)])
			[UIView setAnimationPosition:CGPointMake(290, 450)];
		
		[scrollViewForPageView removeFromSuperview];
		[UIView commitAnimations];
		
		//delete audio note if there
		[self deleteAudioNoteExecute: self];
		
		//delete photo
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
		
		[album removePagesObject:currentPage];
		[[self applicationManagedObjectContext] deleteObject:currentPage];
		
		[pageViewCollection removeObjectAtIndex:currentPageIndex];
		if(currentPageIndex >= [pageViewCollection count])
		{
			currentPageIndex--;
		}
		[self populatePageForSelectedIndex:currentPageIndex];
		[self validate];
		if([pageViewCollection count] == 0)
			[self.navigationController popViewControllerAnimated:YES];
	}
}

- (IBAction)moreOptions: (id)sender{
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Share"
															 delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil
													otherButtonTitles:@"Send as Email", @"Cancel", nil];
	actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
	[actionSheet showInView:self.view]; // show from our table view (pops up in the middle of the table)
	[actionSheet release];
} 

- (IBAction)mailPage: (id)sender{
	MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
	controller.mailComposeDelegate = self;
	[controller setSubject:@"Talking Albums: Sharing with you a Talking Picture"];
	[controller setMessageBody:@"" isHTML:NO];
	UIImage *imageToShare = [self imageForIndex:[self currentIndex]];
	NSData *imageData = UIImageJPEGRepresentation(imageToShare, 1);
	[controller addAttachmentData:imageData mimeType:@"image/jpg" fileName:@"Talking Picture.jpg"];
	NSData *audioData = nil;
	ScrollViewForPageView *scrollViewForPageView = [self.pageViewCollection objectAtIndex:currentPageIndex];
    Page *currentPage = scrollViewForPageView.pageView.page;
	if([currentPage hasAudioNote])
	{
		if(self.audioPlayer)
		{
			[self stopAudioNotePlayback: self];
		}
		NSString *applicationDocumentDirPath = [(PhotoAlbumsAppDelegate *)[[UIApplication sharedApplication] delegate] applicationDocumentsDirectory];
		NSString *audioPath = [NSString stringWithFormat:@"%@/%@",applicationDocumentDirPath, currentPage.audioNotePath];
		if ([[NSFileManager defaultManager] fileExistsAtPath:audioPath]) 
		{
			NSURL *audioURL = [currentPage audioNoteURL];
			audioData = [[[NSData alloc] initWithContentsOfURL:audioURL] autorelease];
			
		}
	}
	
	if(audioData){
		[controller addAttachmentData:audioData mimeType:@"audio/pcm" fileName:@"VoiceNote.mp3"];
	}
	
	[self presentModalViewController:controller animated:YES];
	[controller release];
}

- (IBAction) deletePage: (id) sender
{
	UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"This will delete the selected photo and associated voice note from the Application.\n Do you want to continue?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete" otherButtonTitles:nil];
	actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
	[actionSheet showInView:self.view]; 
	[actionSheet release];

}

- (IBAction) addCaption: (id) sender
{
	NSLog(@"addCaption:");
}


- (void)dealloc 
{
    [pageViewCollection release];
	[albumPhotoDirectoryPath release];
	[albumAudioDirectoryPath release];
	[audioPlayer release];
	[audioRecorder release];
	[recordingTimer invalidate];
	[recordingTimer release];
	[albumView release];
	[pageToolBar release];
	
	[super dealloc];
}

#pragma mark Action Sheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
	if([[actionSheet title] isEqualToString:@"Share"]){
		if(buttonIndex == 0){
			[self mailPage:nil];
		}
	}
	else if([[actionSheet title] isEqualToString:@"This will delete the selected photo and associated voice note from the Application.\n Do you want to continue?"]){
		if(buttonIndex == 0){
			[self deletePageExecute:nil];
			}
		else
			NSLog(@"Cancel");	
	}
	else{
		if(buttonIndex == 0){
			[self deleteAudioNoteExecute:nil];
		}else{
			NSLog(@"Cancel");
		}

	}
}

#pragma mark Mail delegate

-(void)mailComposeController:(MFMailComposeViewController*)controller 
		 didFinishWithResult: (MFMailComposeResult)result 
					   error:(NSError*)error {
	[self dismissModalViewControllerAnimated:YES];
}

@end
