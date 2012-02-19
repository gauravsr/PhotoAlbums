//
//  AlbumListViewController.m
//  PhotoAlbums
//
//  Created by raheja on 23/06/10.
//  Copyright Xebia IT Architects India Private Limited 2010. All rights reserved.
//

#import "AlbumListViewController.h"
#import "AlbumViewController.h"
#import "Album.h"
#import "AlbumInformationController.h"
#import "PhotoRepository.h"
#import "PhotoUtil.h"

@implementation AlbumListViewController

@synthesize fetchedResultsController, managedObjectContext;
@synthesize albumControllerDictionary;

#pragma mark -
#pragma mark View lifecycle

-(void)editTableView:(UIBarButtonItem *)sender {
    if([[sender title] isEqualToString:@"Edit"]) {
        [self.tableView setEditing:YES animated:YES];
        [sender setTitle:@"Done"];
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    else {
        self.navigationItem.rightBarButtonItem.enabled = YES;
        [self.tableView setEditing:NO animated:YES];
        id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResultsController sections] objectAtIndex:0];
        unsigned count =  [sectionInfo numberOfObjects];
        [sender setTitle:@"Edit"];
        if(count > 0) {
            [sender setEnabled:YES];
        }
        else {
            [sender setEnabled:NO];
        }
    }
}

-(void)handleVisibilityOfEditButton {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResultsController sections] objectAtIndex:0];
    unsigned count =  [sectionInfo numberOfObjects];
	if(count > 0) {
        if([self.tableView isEditing]) {
            self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(editTableView:)];
        }
        else {
            self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStyleDone target:self action:@selector(editTableView:)];
        }
    }
    else {
        NSLog(@"count == 0");
    }
}

- (void)drawHelperTexts{
	id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResultsController sections] objectAtIndex:0];
    unsigned count =  [sectionInfo numberOfObjects];
	if(count == 0){
		if(mHelpertextLabel == nil)
			mHelpertextLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 300, 50)];
		
		[mHelpertextLabel setText:@"Add albums and import photos from iPhone Library"];
		[mHelpertextLabel setFont:[UIFont systemFontOfSize:12]];
		[mHelpertextLabel setTextColor:[UIColor grayColor]];
		[self.view addSubview:mHelpertextLabel];
	}else
	{
		[mHelpertextLabel removeFromSuperview];
		[mHelpertextLabel release];
		mHelpertextLabel = nil;
	}
}


- (void) viewDidLoad 
{
    [super viewDidLoad];
	
	if(!albumControllerDictionary)
	{
		albumControllerDictionary = [[NSMutableDictionary alloc] init];
	}	
    [[UIBarButtonItem appearance] setTintColor:[UIColor blackColor]];
    //UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject)];
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewAlbum)];
	self.navigationItem.rightBarButtonItem = addButton;
    [addButton release];
	
	self.title = @"Albums";
	self.tableView.rowHeight = 70;
	NSError *error = nil;
	if (![[self fetchedResultsController] performFetch:&error])  	{
		/*
		 Replace this implementation with code to handle the error appropriately.
		 
		 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
		 */
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}
	
	[self drawHelperTexts];
    [self handleVisibilityOfEditButton];
}


- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}


- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    //update cellIcons
}
/*
 - (void) viewWillDisappear:(BOOL)animated {
 [super viewWillDisappear:animated];
 }
 */
/*
 - (void) viewDidDisappear:(BOOL)animated {
 [super viewDidDisappear:animated];
 }
 */

- (void) viewDidUnload 
{
	// Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
	// For example: self.myOutlet = nil;
}

/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations.
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

#pragma mark -
#pragma mark Add a new object

- (void) addNewAlbum 
{
	AlbumInformationController *albumInformationController = [[AlbumInformationController alloc] init];
	[self presentModalViewController:albumInformationController animated:true];
    [albumInformationController release];
	[self drawHelperTexts];
}

#pragma mark -
#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    NSInteger numberOfRows;
    
    if(section == 0) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResultsController sections] objectAtIndex:section];
        numberOfRows = [sectionInfo numberOfObjects];
    }
    else {
        //id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResultsControllerForTags sections] objectAtIndex:section];
        //numberOfRows = [sectionInfo numberOfObjects];
    }
    
    return numberOfRows;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(section == 0)
        return @"Albums";
    else
        return @"Tags";
}

// Customize the appearance of table view cells.
- (UITableViewCell *) tableView: (UITableView *)tableView cellForRowAtIndexPath: (NSIndexPath *)indexPath 
{    
    static NSString *CellIdentifier = @"Cell";
	PhotoRepository *photoRepository = [PhotoRepository instance];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) 
	{
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle	reuseIdentifier:CellIdentifier] autorelease];
	}
    
	// Configure the cell.
    if(indexPath.section == 0) {
        NSManagedObject *managedObject = [fetchedResultsController objectAtIndexPath:indexPath];
        NSUInteger count = [[managedObject valueForKey:@"pages"] count];
        
        cell.textLabel.text = [managedObject valueForKey:@"title"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d Photos", count];
        
        UIImage *cellIcon;
        if(count > 0)
        {
            NSArray *pages = [[managedObject valueForKey:@"pages"] allObjects];
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"creationDate" ascending:YES];
            pages = [pages sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
            [sortDescriptor release];
            
            Page *lastPage = [pages objectAtIndex:(count - 1)];
            
            cellIcon = [photoRepository getPhoto: lastPage.imageThumbnailPath];
            if(!cellIcon)
            {
                cellIcon = [photoRepository getPhoto: lastPage.imagePath];
                cellIcon =  [PhotoUtil createThumbnail:cellIcon];
                [photoRepository addPhoto:cellIcon withPhotoID:lastPage.imageThumbnailPath];
                
                //creting thumbnail image if its already not there
                NSData *thumbnailData = [NSData dataWithData:UIImagePNGRepresentation(cellIcon)];	
                [thumbnailData writeToFile:lastPage.imageThumbnailPath atomically:NO];			
            }		
        }
        else
        {
            //This is cached by system, so no need to implement separate cache for it
            cellIcon = [UIImage imageNamed:@"frame_small.png"];
        }
        
        [cell.imageView setImage:cellIcon];	
    }
    else if(indexPath.section == 1) {
        
    }
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{	
	//this is the album object
	Album *selectedObject = (Album *)[[self fetchedResultsController] objectAtIndexPath:indexPath];
	
	AlbumViewController *albumViewController = nil; //[albumControllerDictionary objectForKey:selectedObject.albumID];
	if(!albumViewController)
	{
		albumViewController = [[AlbumViewController alloc] init];
		albumViewController.album = selectedObject;
		[albumViewController validate];
		// VJ Removed caching.
		//[albumControllerDictionary setObject:albumViewController forKey:selectedObject.albumID];
		//[albumViewController release];
	}			
	
	[self.navigationController pushViewController:albumViewController animated:YES];
	
	[albumViewController release];	
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath 
{    
    if (editingStyle == UITableViewCellEditingStyleDelete) 
	{
		Album *selectedObject = (Album *)[[self fetchedResultsController] objectAtIndexPath:indexPath];
		NSString *albumId = [selectedObject albumID];
		NSString *applicationDocumentDirPath = [(PhotoAlbumsAppDelegate *)[[UIApplication sharedApplication] delegate] applicationDocumentsDirectory];
        
		NSString *fullPath = [NSString stringWithFormat:@"%@/%@",applicationDocumentDirPath, albumId];
		// Delete the folder
		[[NSFileManager defaultManager] removeItemAtPath:fullPath error:nil];
		
		// Delete the managed object for the given index path
		NSManagedObjectContext *context = [fetchedResultsController managedObjectContext];
		[context deleteObject:[fetchedResultsController objectAtIndexPath:indexPath]];
		
		// Save the context.
		NSError *error = nil;
		if (![context save:&error]) 
		{
			/*
			 Replace this implementation with code to handle the error appropriately.
			 
			 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
			 */
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			abort();
		}
	}
	
	[self drawHelperTexts];
}


- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath 
{
    // The table view should not be re-orderable.
    return YES;
}


#pragma mark -
#pragma mark Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController 
{    
    if (fetchedResultsController != nil) 
	{
        return fetchedResultsController;
    }
    
    /*
	 Set up the fetched results controller.
	 */
	// Create the fetch request for the entity.
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	// Edit the entity name as appropriate.
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"ListOfAlbumsAndTags" inManagedObjectContext:managedObjectContext];
	[fetchRequest setEntity:entity];
	
	// Set the batch size to a suitable number.
	[fetchRequest setFetchBatchSize:20];
	[fetchRequest setPredicate:	[NSPredicate predicateWithFormat:@"self = %@", [NSNumber numberWithInt:0]]];
	
	// Edit the sort key as appropriate.
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:NO];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	[fetchRequest setSortDescriptors:sortDescriptors];
	// Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
	NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:@"Root"];
    aFetchedResultsController.delegate = self;
	self.fetchedResultsController = aFetchedResultsController;
	
	[aFetchedResultsController release];
	[fetchRequest release];
	[sortDescriptor release];
	[sortDescriptors release];
	
	return fetchedResultsController;
}    


// NSFetchedResultsControllerDelegate method to notify the delegate that all section and object changes have been processed. 
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller 
{
	// In the simplest, most efficient, case, reload the table view.
	[self.tableView reloadData];
	[self drawHelperTexts];
    [self handleVisibilityOfEditButton];
}

/*
 Instead of using controllerDidChangeContent: to respond to all changes, you can implement all the delegate methods to update the table view in response to individual changes.  This may have performance implications if a large number of changes are made simultaneously.
 
 // Notifies the delegate that section and object changes are about to be processed and notifications will be sent. 
 - (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
 [self.tableView beginUpdates];
 }
 
 - (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
 // Update the table view appropriately.
 }
 
 - (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
 // Update the table view appropriately.
 }
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
 [self.tableView endUpdates];
 } 
 */


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning 
{
    [super didReceiveMemoryWarning];
	// Relinquish ownership of any cached data, images, etc that aren't in use.
}

- (void)dealloc 
{
	[fetchedResultsController release];
	[managedObjectContext release];
    [super dealloc];
}


@end

