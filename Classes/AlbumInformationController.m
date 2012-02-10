//
//  AlbumInformationController.m
//  PhotoAlbums
//
//  Created by raheja on 01/10/10.
//  Copyright 2010 Xebia IT Architects India Private Limited. All rights reserved.
//

#import "AlbumInformationController.h"
#import "PhotoAlbumsAppDelegate.h"
#import "Album.h"

@implementation AlbumInformationController

@synthesize titleLabel, hiddenSwitch, nameTextField;
@synthesize	album;

- (void)viewWillAppear:(BOOL)animated 
{
	[super viewWillAppear:animated];
	CGRect frame = [nameTextField frame];
	[nameTextField setFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, 50)];
	[nameTextField becomeFirstResponder];
	[nameTextField setFont:[UIFont systemFontOfSize:18]];
	if(album)
	{
		[titleLabel setText: album.title];
	}	
}

- (void) viewDidAppear:(BOOL)animated
{
	//doing it viewDidAppear instead of viewWillAppear as it is ignored if view is not visible 
	if(album)
	{
		[nameTextField setText: album.title];
	}		
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

#pragma mark Save and Cancel

- (IBAction) save: (id) sender
{	
	NSString *text = [nameTextField text];
    text = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
   
	if( [text isEqualToString:@""])
	{
		return;
	}
	
	PhotoAlbumsAppDelegate *appDelegate = (PhotoAlbumsAppDelegate *)[[UIApplication sharedApplication] delegate];	
	
	// Create a new instance of the entity managed by the fetched results controller.
	NSManagedObjectContext *context = [appDelegate managedObjectContext];
	NSError *error = nil;
	
	if(album)
	{
		album.title = nameTextField.text;
//		album.hidden = hiddenSwitch.on;
	}
	else
	{
		Album *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:@"Album" inManagedObjectContext:context];		
		
		// If appropriate, configure the new managed object.
		[newManagedObject setValue:[NSDate date] forKey:@"creationDate"];
		
		[newManagedObject setValue:[nameTextField text] forKey:@"title"];
		[newManagedObject setValue:[NSNumber numberWithBool:[hiddenSwitch isOn]] forKey:@"hidden" ];		
	}
	
    if (![context save:&error]) 
	{
		/*
		 Replace this implementation with code to handle the error appropriately.
		 
		 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
		 */
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
    }
	
	[self dismissModalViewControllerAnimated:true]; 
}

- (IBAction) cancel: (id) sender
{
	[self dismissModalViewControllerAnimated:true]; 
}

#pragma mark Text Delegate
- (BOOL) textFieldShouldReturn:(UITextField *)textField 
{	
	if (textField == nameTextField) 
	{
		[nameTextField resignFirstResponder];
	}
	return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField 
{
	return FALSE;
}

#pragma mark -

- (void)dealloc 
{
    [super dealloc];
}


@end
