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

@synthesize titleLabel, hiddenSwitch, nameTextField, typeControl;
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
        if(album.isTag.integerValue == 1) {
            [self.typeControl setSelectedSegmentIndex:1];
        }
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

-(IBAction) save:(id)sender {	
	NSString *text = [nameTextField text];
    text = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
   
	if( [text isEqualToString:@""]) {
		return;
	}
	
	PhotoAlbumsAppDelegate *appDelegate = (PhotoAlbumsAppDelegate *)[[UIApplication sharedApplication] delegate];	
	NSManagedObjectContext *context = [appDelegate managedObjectContext];
	NSError *error = nil;
	
    BOOL isTag = NO;
    if(self.typeControl.selectedSegmentIndex == 1) {
        isTag = YES;
    }

	if(album)
	{
		album.title = nameTextField.text;
        album.isTag = [NSNumber numberWithBool:isTag];
        [self dismissModalViewControllerAnimated:true]; 
	}
	else
	{
        // fetching all the albums (their title, to be specific) to check if they already exists
        BOOL isAlbumAlreadyPresent = NO;
        NSError *error;
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Album" 
                                                  inManagedObjectContext:context];
        [fetchRequest setEntity:entity];
        NSArray *results = [[context executeFetchRequest:fetchRequest error:&error] retain];
        
        for(Album *albumObject in results) {
            if(self.typeControl.selectedSegmentIndex == 0) {
                if([albumObject.isTag isEqualToNumber:[NSNumber numberWithInt:0]]) {
                    if([nameTextField.text isEqualToString:[albumObject title]]) {
                        isAlbumAlreadyPresent = YES;
                        break;
                    }
                }
                else {
                    if([nameTextField.text isEqualToString:[albumObject title]]) {
                        isAlbumAlreadyPresent = YES;
                        break;
                    }
                }
            }
        }
        
        if(!isAlbumAlreadyPresent) {
            Album *albumManagedObject = [NSEntityDescription insertNewObjectForEntityForName:@"Album" inManagedObjectContext:context];
            [albumManagedObject setValue:[NSDate date] forKey:@"creationDate"];
		
            [albumManagedObject setValue:[nameTextField text] forKey:@"title"];
            [albumManagedObject setValue:[NSNumber numberWithBool:[hiddenSwitch isOn]] forKey:@"hidden"];	      
            [albumManagedObject setValue:[NSNumber numberWithBool:isTag] forKey:@"isTag"];
            [albumManagedObject addPages:[[NSSet alloc] init]];
            [self dismissModalViewControllerAnimated:true]; 
        }
        else {
            UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Duplicate Album" 
                                                              message:@"Album with this name already exists!" 
                                                             delegate:nil
                                                            cancelButtonTitle:@"OK"
                                                            otherButtonTitles:nil];
            [message show];
        }

	}
	
    if (![context save:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
    }
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
