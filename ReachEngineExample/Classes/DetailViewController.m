//
//  DetailViewController.m
//  ReachEngine
//
//  Created by Tom Irving on 05/10/2010.
//  Copyright 2010 Tom Irving. All rights reserved.
//

#import "DetailViewController.h"
#import "TIReachEngine.h"

@implementation DetailViewController
@synthesize reachEngine;
@synthesize gameDetails;

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	
	TIReachEngine * tempEngine = [[TIReachEngine alloc] initWithAPIKey:@"APIKey-Goes-Here" delegate:self];
	[self setReachEngine:tempEngine];
	[tempEngine release];
	
	[self.navigationItem setTitle:@"Loading..."];
}

- (void)getDetailsForGame:(NSDictionary *)game {
	
	[reachEngine getGameDetailsForGameID:[game objectForKey:@"GameId"]];
}

- (void)reachEngine:(TIReachEngine *)reachEngine didReceiveGameDetails:(NSDictionary *)details forGameID:(NSString *)gameID connection:(TIReachEngineConnection *)connection {
	
	[self setGameDetails:[details objectForKey:@"GameDetails"]];
	[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationTop];
	[self.navigationItem setTitle:[gameDetails objectForKey:@"MapName"]];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [[gameDetails allKeys] count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
	[cell.textLabel setText:[[gameDetails allKeys] objectAtIndex:indexPath.row]];
    
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	[gameDetails release];
	[reachEngine release];
    [super dealloc];
}


@end

