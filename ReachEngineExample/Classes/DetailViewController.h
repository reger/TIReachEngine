//
//  DetailViewController.h
//  ReachEngine
//
//  Created by Tom Irving on 05/10/2010.
//  Copyright 2010 Tom Irving. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TIReachEngine.h"

@interface DetailViewController : UITableViewController <TIReachEngineDelegate> {

	TIReachEngine * reachEngine;
	NSDictionary * gameDetails;
}

@property (nonatomic, retain) TIReachEngine * reachEngine;
@property (nonatomic, retain) NSDictionary * gameDetails;

- (void)getDetailsForGame:(NSDictionary *)game;

@end
