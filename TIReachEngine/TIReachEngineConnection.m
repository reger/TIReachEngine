//
//  TIReachEngineConnection.m
//  TIReachEngine
//
//  Created by Tom Irving on 20/09/2010.
//  Copyright 2010 Tom Irving. All rights reserved.
//

#import "TIReachEngineConnection.h"

@implementation TIReachEngineConnection
@synthesize connectionType;
@synthesize userInfo;

- (void)dealloc {
	[userInfo release];
	[super dealloc];
}

@end
