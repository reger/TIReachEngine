//
//  ReachEngineAppDelegate.m
//  ReachEngine
//
//  Created by Tom Irving on 20/09/2010.
//  Copyright 2010 Tom Irving. All rights reserved.
//

#import "ReachEngineAppDelegate.h"
#import "RootViewController.h"

@implementation ReachEngineAppDelegate

@synthesize window;
@synthesize navigationController;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
	
	UIWindow * aWindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	[self setWindow:aWindow];
	[aWindow release];
	
	RootViewController * rootViewController = [[RootViewController alloc] initWithStyle:UITableViewStylePlain];
	UINavigationController * navController = [[UINavigationController alloc] initWithRootViewController:rootViewController];
	[rootViewController release];
	[self setNavigationController:navController];
	[navController release];
	
    [window addSubview:navigationController.view];
    [window makeKeyAndVisible];

    return YES;
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	[navigationController release];
	[window release];
	[super dealloc];
}


@end

