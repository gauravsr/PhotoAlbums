//
//  AlbumListViewController.m
//  PhotoAlbums
//
//  Created by Gaurav on 20/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AlbumListViewController.h"
#import "AlbumInformationController.h"
#import "Tag.h"
#import "AlbumViewController.h"

@implementation AlbumListViewController

@synthesize albumTagData;
@synthesize managedObjectContext;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View

-(void)drawHelperTexts{
    unsigned count =  [self.albumTagData count];
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

-(void)showAddButtonToAddAlbums {
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewAlbum)];
	self.navigationItem.rightBarButtonItem = addButton;
    [addButton release];
}

-(void)addNewAlbum {
	AlbumInformationController *albumInformationController = [[AlbumInformationController alloc] init];
    albumInformationController.tableView = self.tableView;
	[self presentModalViewController:albumInformationController animated:true];
    [albumInformationController release];
}

-(NSInteger)getTotalNumberOfAlbums {
    NSInteger count = 0;
    for(NSManagedObject *object in self.albumTagData) {
        if([object isKindOfClass:[Album class]]) {
            count++;
        }
    }
    return count;
}

-(NSInteger)getTotalNumberOfTags {
    NSInteger count = 0;
    for(NSManagedObject *object in self.albumTagData) {
        if([object isKindOfClass:[Tag class]]) {
            count++;
        }
    }
    return count;
}

-(void)reloadAlbumViewController:(id)sender {
    [self fetchAlbumsAndTagsFromCoredata];
    [self.tableView reloadData];
	[self drawHelperTexts];
}

-(NSMutableArray *)filterAlbumsFromCoredata {
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    
    for(NSManagedObject *object in self.albumTagData) {
        if([object isKindOfClass:[Album class]]) {
            [arr addObject:object];
        }
    }
    
    return arr;
}

-(NSMutableArray *)filterTagsFromCoredata {
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    
    for(NSManagedObject *object in self.albumTagData) {
        if([object isKindOfClass:[Tag class]]) {
            [arr addObject:object];
        }
    }
    
    return arr;
}

#pragma mark - Core data

-(void)fetchAlbumsAndTagsFromCoredata {
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"ListOfAlbumsAndTags" inManagedObjectContext:managedObjectContext];
    NSError *error;
	[fetchRequest setEntity:entity];
    NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"sorter" ascending:YES];
    NSArray* sortDescriptors = [[[NSArray alloc] initWithObjects: sortDescriptor, nil] autorelease];
    [fetchRequest setSortDescriptors:sortDescriptors];
	albumTagData = [[managedObjectContext executeFetchRequest:fetchRequest error:&error] retain];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(reloadAlbumViewController:) 
                                                 name:@"ReloadAlbumViewController" 
                                               object:nil];
    self.title = @"Albums";
	self.tableView.rowHeight = 70;
    [self fetchAlbumsAndTagsFromCoredata];
    [self drawHelperTexts];
    [self showAddButtonToAddAlbums];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self fetchAlbumsAndTagsFromCoredata];
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if([self.albumTagData count] > 0) {
        return 2;
    }
    else {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numberOfRows;
    
    if(section == 0) {
        numberOfRows = [self getTotalNumberOfAlbums];
    }
    else if(section == 1) {
        numberOfRows = [self getTotalNumberOfTags];
    }
    else {
        numberOfRows = -1;
    }
    return numberOfRows;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if([self.albumTagData count] > 0) {
        if(section == 0) {
            return @"Albums";
        }
        else if(section == 1) {
            return @"Tags";
        }
        else {
            return @"";
        }
    }
    else {
        return @"";
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;


    if(indexPath.section == 0) {
        NSMutableArray *albumArray = [self filterAlbumsFromCoredata];
        Album *album = [albumArray objectAtIndex:indexPath.row];
        cell.textLabel.text = album.title;
        NSUInteger count = [[album valueForKey:@"pages"] count];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d Photos", count];
    }
    else if(indexPath.section == 1) {
        NSMutableArray *tagArray = [self filterTagsFromCoredata];
        Tag *tag = [tagArray objectAtIndex:indexPath.row];
        cell.textLabel.text = tag.title;
        
        //NSUInteger count = [[tag valueForKey:@"page"] count];
        //cell.detailTextLabel.text = [NSString stringWithFormat:@"%d Photos", count];
    }
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    AlbumViewController *albumViewController = nil;
    
    if(indexPath.section == 0) {
        NSMutableArray *listOfAlbums = [self filterAlbumsFromCoredata];
        NSManagedObject *managedObject = [listOfAlbums objectAtIndex:indexPath.row];
        
        if([managedObject isKindOfClass:[Album class]]) {
            
            if(!albumViewController) {
                albumViewController = [[AlbumViewController alloc] init];
                albumViewController.album = (Album *)managedObject;
                [albumViewController validate];
            }			
        }
        else {
            NSLog(@"kuch to gadbad hai!");
        }
    }
    else if(indexPath.section == 1) {
        NSInteger numberOfAlbums = [[self filterAlbumsFromCoredata] count];
        NSManagedObject *managedObject = [self.albumTagData objectAtIndex:(indexPath.row + numberOfAlbums)];
        
        if([managedObject isKindOfClass:[Tag class]]) {
            
            if(!albumViewController) {
                albumViewController = [[AlbumViewController alloc] init];
                //albumViewController.album = (Tag *)managedObject;
                [albumViewController validate];
            }			
        }
        else {
            NSLog(@"kuch to gadbad hai!");
        }
    }
    else {
        
    }
    
	[self.navigationController pushViewController:albumViewController animated:YES];
	
	[albumViewController release];	
}

@end
