//
//  PhotoViewController.h
//  PhotoBook
//
//  Created by raheja on 04/06/10.
//  Copyright Xebia IT Architects India Private Limited 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Album.h"
#import "Page.h"
#import "PageToolBar.h"
#import "AlbumView.h"

#import "AudioQueueObject.h"
#import "AudioRecorder.h"
#import "AudioPlayer.h"
#import "MessageUI/MFMailComposeViewController.h"
#import "TagViewController.h"

#define kSlideShowTimeInterval	3.0

@class TagViewController;

@interface PhotoViewController : UIViewController <UIScrollViewDelegate, 
                                                    UIActionSheetDelegate, 
                                                    MFMailComposeViewControllerDelegate,
                                                    NSFetchedResultsControllerDelegate>
{
	//model
	Album					*album;
	NSString				*albumAudioDirectoryPath;
	NSString				*albumPhotoDirectoryPath;
	NSManagedObjectContext	*applicationManagedObjectContext;
	//Album *albumOfTypeTag;
	NSUInteger				currentPageIndex;
	NSUInteger				selectedIndex;
	BOOL					interruptedOnPlayback;
	
    BOOL					slideshowMode;
    NSDate                  *previousSlideEndTime;
    //NSArray          *fetchedTagsFromCoredata;
    //NSMutableArray *matchingTags;
    
	//view 	
	IBOutlet AlbumView		*albumView;
	IBOutlet PageToolBar	*pageToolBar;
	NSMutableArray			*pageViewCollection;
	//UIView                  *tagsView;
    //UITextField             *textFieldForEnteringTag;
    //UIScrollView            *scrollViewForShowingAndDeletingTags;
    //UITableView *tableViewForShowingAvailableTags;
	//utils
	AudioRecorder			*audioRecorder;
	AudioPlayer				*audioPlayer;
	NSTimer					*recordingTimer;
	NSTimer					*slideShowTimer;
    
    TagViewController *tagViewController;
    BOOL isTagViewControllerShown;
    CGPoint contentOffsetBeforeTagViewIsVisible;
    int currentPageIndexBeforeTagViewIsVisible;
}

//model
@property (nonatomic, assign) Album							*album;
//@property (nonatomic, assign) Album *albumOfTypeTag;
@property (nonatomic, retain) NSString						*albumAudioDirectoryPath;
@property (nonatomic, retain) NSString						*albumPhotoDirectoryPath;
@property (nonatomic, assign) NSManagedObjectContext		*applicationManagedObjectContext;
@property (nonatomic) NSUInteger							currentPageIndex;
@property (nonatomic) BOOL									interruptedOnPlayback;
@property (nonatomic) BOOL									slideshowMode;
@property (nonatomic, retain) NSDate						*previousSlideEndTime;
//@property (nonatomic, retain) NSArray                       *fetchedTagsFromCoredata;
//@property (nonatomic, retain) NSMutableArray *matchingTags;
//view
@property (nonatomic, retain) AlbumView						*albumView;
@property (nonatomic, retain) PageToolBar					*pageToolBar;
@property (nonatomic, retain) NSMutableArray				*pageViewCollection;
//@property (nonatomic, retain) UIView                        *tagsView;
//@property (nonatomic, retain) UITextField                   *textFieldForEnteringTag;
//@property (nonatomic, retain) UITableView *tableViewForShowingAvailableTags;
//@property (nonatomic, retain) UIScrollView                  *scrollViewForShowingAndDeletingTags;
//utils
@property (nonatomic, retain) AudioRecorder					*audioRecorder;
@property (nonatomic, retain) AudioPlayer					*audioPlayer;
@property (nonatomic, retain) NSTimer						*recordingTimer;
@property (nonatomic, retain) NSTimer						*slideShowTimer;
@property (assign) NSUInteger								selectedIndex;

@property (nonatomic, retain) TagViewController *tagViewController;
@property (nonatomic) BOOL isTagViewControllerShown;
@property (nonatomic) CGPoint contentOffsetBeforeTagViewIsVisible;
@property (nonatomic) int currentPageIndexBeforeTagViewIsVisible;

//methods
- (void) validate;
- (void) addPageViewForPage: (Page *)page withImage: (UIImage *)image atIndex: (int)index;

-(IBAction) addCaption: (id) sender;

-(IBAction) addAudioNote:(id)sender;
-(IBAction) saveRecordedAudioNote:(id)sender;
-(IBAction) deleteAudioNote:(id)sender;

-(IBAction) playAudioNote:(id)sender;
-(IBAction) stopAudioNotePlayback:(id)sender;
-(IBAction) pauseAudioNotePlayback:(id)sender;
-(IBAction) resumeAudioNotePlayback:(id)sender;

-(IBAction) deletePage:(id) sender;
-(void)populateAlbum;
-(IBAction)moreOptions:(id)sender;
//-(IBAction)manageTagForThePhoto:(id)sender;

-(void)startSlideShow;
-(void)stopSlideShow;

@end

