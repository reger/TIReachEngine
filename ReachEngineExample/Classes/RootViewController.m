//
//  RootViewController.m
//  ReachEngine
//
//  Created by Tom Irving on 20/09/2010.
//  Copyright 2010 Tom Irving. All rights reserved.
//

#import "RootViewController.h"
#import "DetailViewController.h"

@implementation RootViewController
@synthesize reachEngine;
@synthesize gamesArray;

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
	
	[self.navigationItem setTitle:@"Reach Stats"];
	
	UIBarButtonItem * backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
	[self.navigationItem setBackBarButtonItem:backButton];
	[backButton release];
	
	TIReachEngine * tempEngine = [[TIReachEngine alloc] initWithAPIKey:@"APIKey-Goes-Here" delegate:self];
	[self setReachEngine:tempEngine];
	[tempEngine release];
	
	//[tempEngine getGameMetadata];
	[tempEngine getGamesforPlayer:@"The T0m" ofGameType:TIReachEngineGameTypeAll forPage:0];
	
	/* // Use this to make a search
	TIReachEngineSearch * search = [[TIReachEngineSearch alloc] initWithFileType:TIReachEngineFileTypeImage 
																	   mapFilter:TIReachEngineMapFilterNone
																	engineFilter:TIReachEngineEngineFilterNone 
																	  dateFilter:TIReachEngineDateFilterAll 
																	  sortFilter:TIReachEngineSortFilterHighestRated 
																			page:0 
																			tags:nil];
	[tempEngine getResultsForSearch:search];
	[search release]; // The engine retains it for you, release as normal.
	 */
	
	[self setGamesArray:[NSMutableArray array]];
	gamesLeftToLoad = YES;
	loadingNewGames = YES;
	pageNumber = 0;
	
    [super viewDidLoad];
}

#pragma mark -
#pragma mark Reach engine delegate

- (void)reachEngine:(TIReachEngine *)reachEngine didReceiveSearchResults:(NSDictionary *)results forSearch:(TIReachEngineSearch *)search 
		 connection:(TIReachEngineConnection *)connection {
	NSLog(@"%@", results);
}

- (void)reachEngine:(TIReachEngine *)reachEngine didReceiveMetadata:(NSDictionary *)metadata forConnection:(TIReachEngineConnection *)connection {
	NSLog(@"%@", metadata);
}

- (void)reachEngine:(TIReachEngine *)reachEngine didReceiveGames:(NSDictionary *)games forPlayer:(NSString *)gamertag 
		 ofGameType:(NSString *)gameType forPage:(NSInteger)page connection:(TIReachEngineConnection *)connection {
	
	[self.navigationItem setTitle:[NSString stringWithFormat:@"%@'s Games", gamertag]];
	
	pageNumber = page;
	NSArray * recentGames = [games objectForKey:@"RecentGames"];
	
	gamesLeftToLoad = [[games objectForKey:@"HasMorePages"] boolValue];
	
	if (gamesLeftToLoad){
		NSMutableArray * newCellIndexs = [[NSMutableArray alloc] init];
	
		for (int i = 0; i < [recentGames count]; i++){
			[newCellIndexs addObject:[NSIndexPath indexPathForRow:i + ([gamesArray count]) inSection:0]];
		}
	
		[gamesArray addObjectsFromArray:recentGames];
	
		[self.tableView insertRowsAtIndexPaths:[NSArray arrayWithArray:newCellIndexs] withRowAnimation:UITableViewRowAnimationFade];
		[newCellIndexs release];
		
		if (!gamesLeftToLoad){
			[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:[gamesArray count] inSection:0]] 
								  withRowAnimation:UITableViewRowAnimationFade];
		}
	}
	else
	{
		[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:[gamesArray count] inSection:0]] 
							  withRowAnimation:UITableViewRowAnimationFade];
	}
	
	loadingNewGames = NO;
}

- (void)reachEngine:(TIReachEngine *)reachEngine connection:(TIReachEngineConnection *)connection didFailWithError:(NSError *)error {
	NSLog(@"%@", [error localizedDescription]);
}


#pragma mark -
#pragma mark Table view data source

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	if (gamesLeftToLoad){
		return [gamesArray count] + 1;
	}
	
    return [gamesArray count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
	
	if (indexPath.row == [gamesArray count] && gamesLeftToLoad){
		[cell.textLabel setTextColor:[UIColor grayColor]];
		[cell.textLabel setText:@"Loading..."];
		[cell.detailTextLabel setText:nil];
		[cell setAccessoryType:UITableViewCellAccessoryNone];
		
		UIActivityIndicatorView * activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		[activityView startAnimating];
		[cell setAccessoryView:activityView];
		[activityView release];
		
		[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	}
	else
	{
		[cell setAccessoryView:nil];
		[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
		[cell.textLabel setTextColor:[UIColor blackColor]];
		[cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
		
		NSDictionary * dict = [gamesArray objectAtIndex:indexPath.row];
		[cell.textLabel setText:[dict objectForKey:@"GameVariantName"]];
		[cell.detailTextLabel setText:[dict objectForKey:@"MapName"]];
	}

    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (indexPath.row != [gamesArray count]){
		
		DetailViewController * viewController = [[DetailViewController alloc] initWithStyle:UITableViewStylePlain];
		[self.navigationController pushViewController:viewController animated:YES];
		[viewController getDetailsForGame:[gamesArray objectAtIndex:indexPath.row]];
		[viewController release];
	}
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	
	if (scrollView.contentOffset.y >= scrollView.contentSize.height - scrollView.frame.size.height && !loadingNewGames && gamesLeftToLoad){
		
		[reachEngine getGamesforPlayer:@"The T0m" ofGameType:TIReachEngineGameTypeAll forPage:pageNumber + 1];
		loadingNewGames = YES;
	}
}

#pragma mark -
#pragma mark Memory management
- (void)dealloc {
	[gamesArray release];
	[reachEngine release];
    [super dealloc];
}


@end

