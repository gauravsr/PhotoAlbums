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
#import "OverlayViewController.h"

@implementation AlbumListViewController

@synthesize fetchedResultsController, managedObjectContext;
@synthesize albumOfTypeTag;

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

//-(void)handleVisibilityOfEditButton {
//    id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResultsController sections] objectAtIndex:0];
//    unsigned count =  [sectionInfo numberOfObjects];
//    if(count > 0) {
//        if([self.tableView isEditing]) {
//            self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(editTableView:)];
//        }
//        else {
//            self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStyleDone target:self action:@selector(editTableView:)];
//        }
//    }
//    else {
//        NSLog(@"count == 0");
//    }
//}

- (void)drawHelperTexts{
    //    id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResultsController sections] objectAtIndex:0];
    //    unsigned count =  [sectionInfo numberOfObjects];
    //	if(count == 0){
    //		if(mHelpertextLabel == nil)
    //			mHelpertextLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 300, 50)];
    //		
    //		[mHelpertextLabel setText:@"Add albums and import photos from iPhone Library"];
    //		[mHelpertextLabel setFont:[UIFont systemFontOfSize:12]];
    //		[mHelpertextLabel setTextColor:[UIColor grayColor]];
    //		[self.view addSubview:mHelpertextLabel];
    //	}else
    //	{
    //		[mHelpertextLabel removeFromSuperview];
    //		[mHelpertextLabel release];
    //		mHelpertextLabel = nil;
    //	}
}


- (void) viewDidLoad 
{
    [super viewDidLoad];
	
    //[[UIBarButtonItem appearance] setTintColor:[UIColor blackColor]];
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:nil];
	self.navigationItem.leftBarButtonItem = editButton;
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewAlbum)];
	self.navigationItem.rightBarButtonItem = addButton;
    [addButton release];
	
	self.title = @"Albums";
	self.tableView.rowHeight = 70;
	NSError *error = nil;
	if (![[self fetchedResultsController] performFetch:&error])  	{
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}
    
	[self drawHelperTexts];
    //[self handleVisibilityOfEditButton];
    
    searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    searchResults = [[NSMutableArray alloc] init];
    searching = NO;
    letUserSelectRow = YES;
}


- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}


- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    //update cellIcons
}

- (void) viewDidUnload {
}

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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if(searching) {
        return 1;
    }
    else {
        NSInteger count = [[fetchedResultsController sections] count];
        return count;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(searching)
        return @"";
    
    if(section == 0) {
        return @"Albums";
    }
    else {
        return @"Tags";
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (searching)
        return [searchResults count];
    else {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResultsController sections] objectAtIndex:section];
        return [sectionInfo numberOfObjects];
    }
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
    
    NSUInteger count;
    NSManagedObject *managedObject;
    
    if(searching) {
        managedObject = [searchResults objectAtIndex:indexPath.row];
        count = [[managedObject valueForKey:@"pages"] count];
        cell.textLabel.text = [managedObject valueForKey:@"title"];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d Photos", [[managedObject valueForKey:@"pages"] count]];
    }
    else {
        managedObject = [fetchedResultsController objectAtIndexPath:indexPath];
        count = [[managedObject valueForKey:@"pages"] count];
        
        //cell.textLabel.text = [NSString stringWithFormat:@"%@ (%d)",[managedObject valueForKey:@"title"], count];
        cell.textLabel.text = [managedObject valueForKey:@"title"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d Photos", count];
    }   
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
    
    return cell;
}

- (NSIndexPath *)tableView :(UITableView *)theTableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(letUserSelectRow)
        return indexPath;
    else
        return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{	
    Album *selectedObject = nil;
    if(searching) {
        selectedObject = [searchResults objectAtIndex:indexPath.row];
    }
    else {
        selectedObject = (Album *)[[self fetchedResultsController] objectAtIndexPath:indexPath];
	}
	AlbumViewController *albumViewController = nil;
	if(!albumViewController)
	{
		albumViewController = [[AlbumViewController alloc] init];
		albumViewController.album = selectedObject;
        albumViewController.albumOfTypeTag = self.albumOfTypeTag;
		[albumViewController validate];
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
		if (![context save:&error]) {
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
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Album" inManagedObjectContext:managedObjectContext];
	[fetchRequest setEntity:entity];
	
	// Set the batch size to a suitable number.
	[fetchRequest setFetchBatchSize:20];
	[fetchRequest setPredicate:	[NSPredicate predicateWithFormat:@"hidden = %@", [NSNumber numberWithInt:0]]];
	
	// Edit the sort key as appropriate.
	NSSortDescriptor *sortDescriptorTag = [[NSSortDescriptor alloc] initWithKey:@"isTag" ascending:YES];
    NSSortDescriptor *sortDescriptorDate = [[NSSortDescriptor alloc] initWithKey:@"creationDate" ascending:NO];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptorTag, sortDescriptorDate, nil];
	[fetchRequest setSortDescriptors:sortDescriptors];
	// Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
	NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:@"sectionType" cacheName:@"Root"];
    aFetchedResultsController.delegate = self;
	self.fetchedResultsController = aFetchedResultsController;
	
	[aFetchedResultsController release];
	[fetchRequest release];
	[sortDescriptorTag release];
    [sortDescriptorDate release];
	[sortDescriptors release];
	
	return fetchedResultsController;
}    


// NSFetchedResultsControllerDelegate method to notify the delegate that all section and object changes have been processed. 
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller 
{
	// In the simplest, most efficient, case, reload the table view.
	[self.tableView reloadData];
	[self drawHelperTexts];
    //[self handleVisibilityOfEditButton];
}

#pragma mark Search

-(NSMutableArray *)fetchLabelOfAllAlbumsAndTags {
    
    NSMutableArray *list = [[NSMutableArray alloc] init];
    NSMutableArray *albumObject = [[NSMutableArray alloc] init];
    NSMutableArray *albumTitle = [[NSMutableArray alloc] init];
    
    for(NSManagedObject *managedObject in [fetchedResultsController fetchedObjects]) {
        [albumObject addObject:managedObject];
        [albumTitle addObject:[(Album *)managedObject title]];
    }
    NSDictionary *albumObjectDict = [NSDictionary dictionaryWithObject:albumObject forKey:@"object"];
    NSDictionary *albumTitleDict = [NSDictionary dictionaryWithObject:albumTitle forKey:@"title"];
    
    [list addObject:albumObjectDict];
    [list addObject:albumTitleDict];
    
    return list;
}

- (void) searchBarTextDidBeginEditing:(UISearchBar *)theSearchBar {
    
    if(ovController == nil)
        ovController = [[OverlayViewController alloc] initWithNibName:@"OverlayView" bundle:[NSBundle mainBundle]];
    
    CGFloat yaxis = self.navigationController.navigationBar.frame.size.height;
    CGFloat width = self.view.frame.size.width;
    CGFloat height = self.view.frame.size.height;
    
    CGRect frame = CGRectMake(0, yaxis, width, height);
    ovController.view.frame = frame;
    ovController.view.backgroundColor = [UIColor grayColor];
    ovController.view.alpha = 0.5;
    
    ovController.viewController = self;
    
    [self.tableView insertSubview:ovController.view aboveSubview:self.parentViewController.view];
    
    searching = YES;
    letUserSelectRow = NO;
    self.tableView.scrollEnabled = NO;
    
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc]
                                               initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                               target:self action:@selector(doneSearching_Clicked:)] autorelease];
}

- (void)searchBar:(UISearchBar *)theSearchBar textDidChange:(NSString *)searchText {
    [searchResults removeAllObjects];
    
    if([searchText length] > 0) {
        [ovController.view removeFromSuperview];
        searching = YES;
        letUserSelectRow = YES;
        self.tableView.scrollEnabled = YES;
        [self searchTableView];
    }
    else {
        [self.tableView insertSubview:ovController.view aboveSubview:self.parentViewController.view];
        searching = NO;
        letUserSelectRow = NO;
        self.tableView.scrollEnabled = NO;
    }
    
    [self.tableView reloadData];
}

- (void) searchBarSearchButtonClicked:(UISearchBar *)theSearchBar {
    
    [self searchTableView];
}

-(void)searchTableView {
    
    NSString *searchText = searchBar.text;
    NSMutableArray *searchArray = [[NSMutableArray alloc] init];
    
    NSMutableArray *albumTitleArray = [[NSMutableArray alloc] init];
    NSMutableArray *albumObjectArray = [[NSMutableArray alloc] init];
    
    for (NSDictionary *dictionary in [self fetchLabelOfAllAlbumsAndTags]) {
        [albumTitleArray addObjectsFromArray:[dictionary objectForKey:@"title"]];
        [albumObjectArray addObjectsFromArray:[dictionary objectForKey:@"object"]];
    }
    
    for (NSString *sTemp in albumTitleArray){
        NSRange titleResultsRange = [sTemp rangeOfString:searchText options:NSCaseInsensitiveSearch];
        
        if (titleResultsRange.length > 0) {
            int indexInAlbumTitleArray = [albumTitleArray indexOfObject:sTemp];
            [searchResults addObject:[albumObjectArray objectAtIndex:indexInAlbumTitleArray]];
        }
        
    }
    
    [searchArray release];
    searchArray = nil;
}

- (void) doneSearching_Clicked:(id)sender {
    
    searchBar.text = @"";
    [searchBar resignFirstResponder];
    
    letUserSelectRow = YES;
    searching = NO;
    self.navigationItem.rightBarButtonItem = nil;
    self.tableView.scrollEnabled = YES;
    
    [ovController.view removeFromSuperview];
    [ovController release];
    ovController = nil;
    
    [self.tableView reloadData];
}

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

