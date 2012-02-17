//
//  PageToolBar.m
//  PhotoBook
//
//  Created by raheja on 13/06/10.
//  Copyright 2010 Xebia IT Architects India Private Limited. All rights reserved.
//

#import "PageToolBar.h"


@implementation PageToolBar

@synthesize defaultToolBar, addAudioNoteButton, playAudioNoteButton;
@synthesize recordAudioNoteToolBar, recordingLabel, recordingTimer, recordingStartDate;
@synthesize playAudioNoteToolBar, pauseAudioNotePlaybackButton, resumeAudioNotePlaybackButton;
@synthesize audioAvailable;


- (void)awakeFromNib{
	
	[playingLabel setText:@"Playing..."];
}

- (id)initWithFrame:(CGRect)frame 
{
    if (self = [super initWithFrame:frame]) 
	{
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect 
{
}

- (void) validateDefaultToolBar
{

	[addAudioNoteButton setHidden:audioAvailable];
	[playAudioNoteButton setHidden:!audioAvailable];
}

- (void) setAudioAvailable: (BOOL) value
{
	audioAvailable = value;
	[self validateDefaultToolBar];
}

- (void) hideRecordAudioNoteToolBar
{
	[recordAudioNoteToolBar setHidden:YES];
	
	//stop timer
	if(recordingTimer != nil)
	{
		[recordingTimer invalidate];
		[recordingTimer release];
		recordingTimer = nil;
	}
	
	if(recordingStartDate != nil)
	{
		[recordingStartDate release];
		recordingStartDate = nil;
	}
}

- (void)updateRecordingLabel:(NSTimer *)theTimer
{
	NSString *secondsPrefix = @"";
	NSString *minutesPrefix = @"";
	NSString *hoursPrefix = @"";
	
	NSInteger timeElapsed = -[recordingStartDate timeIntervalSinceNow];
	
	NSInteger seconds = timeElapsed % 60;
	if(seconds < 10)
	{
		secondsPrefix = @"0";
	}
	
	NSInteger minutes = (timeElapsed % (60 * 60)) / 60;
	if(minutes < 10)
	{
		minutesPrefix = @"0";
	}
	
	NSInteger hours = timeElapsed / (60 * 60);
	if(hours < 10)
	{
		hoursPrefix = @"0";
	}
	
	[recordingLabel setText:[NSString stringWithFormat:@"%@%d:%@%d:%@%d", hoursPrefix, hours, minutesPrefix, minutes, secondsPrefix, seconds]];
}

- (void) showRecordAudioNoteToolBar
{	
	[defaultToolBar setHidden:YES];
	[recordAudioNoteToolBar setHidden:NO];
	[playAudioNoteToolBar setHidden:YES];
	
	
	//reset recordingLabel and recordingStartDate
	[recordingLabel setText:@"00:00:00"];
	recordingStartDate = [[NSDate alloc] init];
	
	//start timer
	NSTimer *recTimer = [NSTimer	scheduledTimerWithTimeInterval:1.0 
													  target:self 
													selector:@selector(updateRecordingLabel:)
													userInfo: nil
													 repeats:YES];
	self.recordingTimer = recTimer;
}

- (void) showDefaultToolBar
{	
	[self validateDefaultToolBar];
	
	[defaultToolBar setHidden:NO];
	[self hideRecordAudioNoteToolBar];
	[playAudioNoteToolBar setHidden:YES];
}


- (void) showPlayAudioNoteToolBar
{
	[self setAudioPlaybackNormalState];
	[defaultToolBar setHidden:YES];
	[self hideRecordAudioNoteToolBar];	
	[playAudioNoteToolBar setHidden:NO];
}

- (void) setAudioPlaybackPauseState;
{
	[pauseAudioNotePlaybackButton setHidden:YES];
	[resumeAudioNotePlaybackButton setHidden:NO];
}

- (void) setAudioPlaybackNormalState;
{
	[pauseAudioNotePlaybackButton setHidden:NO];
	[resumeAudioNotePlaybackButton setHidden:YES];	
}

- (void)dealloc 
{
    [super dealloc];
}

@end
