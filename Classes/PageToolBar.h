//
//  PageToolBar.h
//  PhotoBook
//
//  Created by raheja on 13/06/10.
//  Copyright 2010 Xebia IT Architects India Private Limited. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PageToolBar : UIView 
{
	//defaultToolBar
	IBOutlet UIView							*defaultToolBar;	
	IBOutlet UIButton						*addAudioNoteButton;
	IBOutlet UIButton						*playAudioNoteButton;
	
	//recordAudioNoteToolBar
	IBOutlet UIView							*recordAudioNoteToolBar;
	IBOutlet UILabel						*recordingLabel;
	NSTimer									*recordingTimer;
	NSDate									*recordingStartDate;
	
	//playAudioNoteToolBar
	IBOutlet UIView							*playAudioNoteToolBar;
	IBOutlet UIButton						*pauseAudioNotePlaybackButton;
	IBOutlet UIButton						*resumeAudioNotePlaybackButton;
	IBOutlet UILabel						*playingLabel;
	
	//Model
	BOOL									audioAvailable;	
}

@property (nonatomic, retain) UIView		*defaultToolBar;
@property (nonatomic, retain) UIButton		*addAudioNoteButton;
@property (nonatomic, retain) UIButton		*playAudioNoteButton;

@property (nonatomic, retain) UIView		*recordAudioNoteToolBar;
@property (nonatomic, retain) UILabel		*recordingLabel;
@property (nonatomic, retain) NSTimer		*recordingTimer;
@property (nonatomic, retain) NSDate		*recordingStartDate;

@property (nonatomic, retain) UIView		*playAudioNoteToolBar;
@property (nonatomic, retain) UIButton		*pauseAudioNotePlaybackButton;
@property (nonatomic, retain) UIButton		*resumeAudioNotePlaybackButton;

@property (nonatomic) BOOL					audioAvailable;

- (void) showDefaultToolBar;
- (void) showRecordAudioNoteToolBar;
- (void) showPlayAudioNoteToolBar;

- (void) setAudioPlaybackNormalState;
- (void) setAudioPlaybackPauseState;

@end
