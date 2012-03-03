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
@synthesize albumOfTypeTag;
@synthesize searchBar;
@synthesize searchResults;
@synthesize isSearching;

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
    
    searchBar.delegate = self;
    
    isSearching = NO;
    
	[self drawHelperTexts];
    //[self handleVisibilityOfEditButton];
    
    for (UIView *view in searchBar.subviews){        
        if ([view isKindOfClass: [UITextField class]]) {
            UITextField *tf = (UITextField *)view;
            tf.delegate = self;
            break;
        }
    }
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
    if(isSearching) {
        return 1;
    }
    else {
        NSInteger count = [[fetchedResultsController sections] count];
        return count;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(isSearching) {
        return @"";
    }
    
    if(section == 0) {
        return @"Albums";
    }
    else {
        return @"Tags";
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    if(isSearching) {
        return [self.searchResults count];
    }
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
    if(isSearching) {
        cell.textLabel.text = [self.searchResults objectAtIndex:indexPath.row];
    }
    else {
        // Configure the cell.
        NSManagedObject *managedObject = [fetchedResultsController objectAtIndexPath:indexPath];
        NSUInteger count = [[managedObject valueForKey:@"pages"] count];
        
        //cell.textLabel.text = [NSString stringWithFormat:@"%@ (%d)",[managedObject valueForKey:@"title"], count];
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
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{	
    if(isSearching) {
        [searchBar resignFirstResponder];
    }
    
	Album *selectedObject = (Album *)[[self fetchedResultsController] objectAtIndexPath:indexPath];
	
	AlbumViewController *albumViewController = nil; //[albumControllerDictionary objectForKey:selectedObject.albumID];
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

-(NSMutableArray *)fetchLabelOfAllAlbumsAndTags {
    NSMutableArray *list = [[NSMutableArray alloc] init];
    for(NSManagedObject *managedObject in [fetchedResultsController fetchedObjects]) {
        [list addObject:[(Album *)managedObject title]];
    }
    return list;
}

#pragma mark Search

-(void)doSearch {
    searchResults = [[NSMutableArray alloc] init];
    NSString *searchString = searchBar.text;
    
    for(NSString *temp in [self fetchLabelOfAllAlbumsAndTags]) {
        NSRange searchResultsRange = [temp rangeOfString:searchString options:NSCaseInsensitiveSearch];
        
        if(searchResultsRange.length > 0) {
            [searchResults addObject:temp];
        }
    }
}

-(void)searchBarTextDidBeginEditing:(UISearchBar *)theSearchBar {
    isSearching = YES;
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)theSearchBar {
    [self doSearch];
    [theSearchBar resignFirstResponder];
}

-(void)searchBar:(UISearchBar *)theSearchBar textDidChange:(NSString *)searchText {
    if([searchText length] > 0) {
        isSearching = YES;
        [self doSearch];
    }
    else {
        isSearching = NO;
    }
    [self.tableView reloadData];
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    isSearching = NO;
    [searchBar resignFirstResponder];
    [self.tableView reloadData];
    return YES;
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

