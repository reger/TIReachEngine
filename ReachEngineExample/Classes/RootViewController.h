//
//  RootViewController.h
//  ReachEngine
//
//  Created by Tom Irving on 20/09/2010.
//  Copyright 2010 Tom Irving. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TIReachEngine.h"

@interface RootViewController : UITableViewController <TIReachEngineDelegate> {
	
	TIReachEngine * reachEngine;
	NSMutableArray * gamesArray;
	
	BOOL gamesLeftToLoad;
	BOOL loadingNewGames;
	NSInteger pageNumber;
}

@property (nonatomic, retain) TIReachEngine * reachEngine;
@property (nonatomic, retain) NSMutableArray * gamesArray;

@end
