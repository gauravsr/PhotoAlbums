//
//  TagViewController.m
//  PhotoAlbums
//
//  Created by Gaurav on 01/03/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TagViewController.h"
#import "Album.h"
#import "ScrollViewForPageView.h"

#define TAGS_PER_ROW 2
#define TAG_WIDTH 130
#define TAG_HEIGHT 20

@implementation TagViewController

@synthesize albumOfTypeTag, viewController, tagTitle, fetchedTagsFromCoredata, scrollView, tableViewForShowingAvailableTags, matchingTags, currentPageIndex;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
    return YES;
}

-(NSString *)getTrimmedString:(NSString *)str {
    NSString *trimmedString = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return trimmedString;
}

-(CGSize)contentSizeForTagScrollView:(int)index {
    return CGSizeMake(0, (TAG_HEIGHT + 20) * index);
}

-(void)addTableViewForAutoSuggestingTags {
    tableViewForShowingAvailableTags.delegate = self;
    tableViewForShowingAvailableTags.dataSource = self;
    tableViewForShowingAvailableTags.userInteractionEnabled = YES;
    tableViewForShowingAvailableTags.hidden = YES;
}

-(NSMutableArray *)listOfAlbumLabelsOfTypeTag {
    NSMutableArray *list = [[NSMutableArray alloc] init];
    NSError *error;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Album" 
                                              inManagedObjectContext:viewController.applicationManagedObjectContext];
    [fetchRequest setEntity:entity];
    fetchedTagsFromCoredata = [[viewController.applicationManagedObjectContext executeFetchRequest:fetchRequest error:&error] retain];
    
    ScrollViewForPageView *scrollViewForPageView = [viewController.pageViewCollection objectAtIndex:currentPageIndex];
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

-(void)showTags {
    for(UIView *view in scrollView.subviews) {
        [view removeFromSuperview];
    }
    
    NSMutableArray *list = [self listOfAlbumLabelsOfTypeTag];
    
    UILabel *noTagLabel = [[UILabel alloc] initWithFrame:CGRectMake(55, 50, 250, 20)];
    noTagLabel.text = @"No tags found for this photo.";
    [noTagLabel setFont:[UIFont systemFontOfSize:12]];
    noTagLabel.textColor = [UIColor grayColor];
    if([list count] == 0) {
        [scrollView addSubview:noTagLabel];
    }
    else {
        [noTagLabel removeFromSuperview];  
    }
    
    
    int row = -1;
    int col = 0;
    int x,y;
    
    for(int i=0; i<[list count]; i++) {
        
        if(i % TAGS_PER_ROW == 0) {
            row++;
            col = 0;
        }
        else if(i > 0) {
            col++;
        }
        
        x = (TAG_WIDTH + 10) * col + 10;
        y = (TAG_HEIGHT + 10) * row + 10;
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        button.frame = CGRectMake(x, y, TAG_WIDTH, TAG_HEIGHT);
        
        NSMutableString *title = [[NSMutableString alloc] init];
        [title appendString:@"    "];
        [title appendString:(NSString *)[list objectAtIndex:i]];
        [button setTitle:title forState:UIControlStateNormal];
        [button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        button.userInteractionEnabled = YES;
        [button addTarget:self action:@selector(deleteTag:) forControlEvents:UIControlEventTouchUpInside];
        [scrollView addSubview:button]; 
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(TAG_WIDTH - 25, 3, 15, 15)];
        [imageView setImage:[UIImage imageNamed:@"delete.gif"]];
        [button addSubview:imageView];
        
        scrollView.contentSize = [self contentSizeForTagScrollView:row];
        
        for(UIView *label in button.subviews) {
            if([label isKindOfClass:[UILabel class]]) {
                CGRect rect = label.frame;
                rect.origin.x = -50;
                label.frame = rect;
            }
        }
    }
}

-(void)deleteTag:(id)sender {
    UILabel *selectedTag = [(UIButton *)sender titleLabel];
    [sender removeFromSuperview];
    
    ScrollViewForPageView *scrollViewForPageView = [viewController.pageViewCollection objectAtIndex:currentPageIndex];
    Page *currentPage = scrollViewForPageView.pageView.page;
    
    NSError *error;
    for(Album *albumObject in self.fetchedTagsFromCoredata) {
        if([albumObject.isTag isEqualToNumber:[NSNumber numberWithInt:1]]) {
            for(Page *page in albumObject.pages) {
                if([currentPage isEqual:page]) {
                    if([[self getTrimmedString:[selectedTag text]] isEqualToString:[albumObject title]]) {
                        [albumObject removePagesObject:currentPage];
                        if (![viewController.applicationManagedObjectContext save:&error]) {
                            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                            abort();
                        }
                        break;
                    }
                }
            }
        }
    }
    
    [self showTags];
}

-(NSMutableArray *)filterAlbumsOfTypeTag {
    NSMutableArray *list = [[NSMutableArray alloc] init];
    
    for(Album *currentAlbum in fetchedTagsFromCoredata) {
        if([currentAlbum.isTag isEqualToNumber:[NSNumber numberWithInt:1]]) {
            [list addObject:currentAlbum];
        }
    }
    
    return list;
}

-(void)addTag {
    NSString *trimmedTagTitle = [tagTitle text];
    trimmedTagTitle = [trimmedTagTitle stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
	NSError *error = nil;
    BOOL isTagAlreadyPresent = NO;
    Album *tempAlbumObject;
    
    ScrollViewForPageView *scrollViewForPageView = [viewController.pageViewCollection objectAtIndex:currentPageIndex];
    Page *page = scrollViewForPageView.pageView.page;
    
    NSMutableArray *listOfAlbumsOfTypeTag = [self filterAlbumsOfTypeTag];
    
    if([listOfAlbumsOfTypeTag count] == 0) {
        albumOfTypeTag = [NSEntityDescription insertNewObjectForEntityForName:@"Album" 
                                                       inManagedObjectContext:[viewController applicationManagedObjectContext]];
        [albumOfTypeTag setValue:trimmedTagTitle forKey:@"title"];
        [albumOfTypeTag addPagesObject:page];
        [albumOfTypeTag setValue:[NSDate date] forKey:@"creationDate"];
        [albumOfTypeTag setValue:[NSNumber numberWithBool:1] forKey:@"isTag"];
        
        if (![[viewController applicationManagedObjectContext] save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
    else {
        for(Album *currentAlbum in listOfAlbumsOfTypeTag) {
            if([[currentAlbum valueForKey:@"title"] isEqualToString:trimmedTagTitle]) {
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
            if (![[viewController applicationManagedObjectContext] save:&error]) {
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                abort();
            }
        }
        else {
            albumOfTypeTag = [NSEntityDescription insertNewObjectForEntityForName:@"Album" 
                                                           inManagedObjectContext:[viewController applicationManagedObjectContext]];
            [albumOfTypeTag setValue:trimmedTagTitle forKey:@"title"];
            [albumOfTypeTag addPagesObject:page];
            [albumOfTypeTag setValue:[NSDate date] forKey:@"creationDate"];
            [albumOfTypeTag setValue:[NSNumber numberWithBool:1] forKey:@"isTag"];
            
            if (![[viewController applicationManagedObjectContext] save:&error]) {
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                abort();
            }
        }
    }
    
    [self showTags];
}

-(IBAction)addTagHandler:(id)sender {
    tableViewForShowingAvailableTags.hidden = YES;
    [self addTag];
    tagTitle.text = @"";
}

-(IBAction)cancel:(id)sender {
	[self dismissModalViewControllerAnimated:true];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.matchingTags = [[NSMutableArray alloc] init];
    [self addTableViewForAutoSuggestingTags];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    [tagTitle becomeFirstResponder];
    [self showTags];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

-(NSMutableArray *)listOfTagsAvailableInAllAlbums {
    NSMutableArray *list = [[NSMutableArray alloc] init];
    NSError *error;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Album" 
                                              inManagedObjectContext:viewController.applicationManagedObjectContext];
    [fetchRequest setEntity:entity];
    NSArray *result = [[viewController.applicationManagedObjectContext executeFetchRequest:fetchRequest error:&error] retain];
    
    for(Album *albumObject in result) {
        if(albumObject.isTag == [NSNumber numberWithInt:1]) {
            [list addObject:albumObject.title];
        }
    }
    
    [fetchRequest release];
    return list;
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

#pragma mark Textfield delegate methods

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    tableViewForShowingAvailableTags.hidden = NO;
    
    NSString *substring = [NSString stringWithString:tagTitle.text];
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
    tagTitle.text = selectedCell.textLabel.text;
    
    tableViewForShowingAvailableTags.hidden = YES;
    
}

@end
