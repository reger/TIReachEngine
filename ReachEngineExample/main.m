//
//  main.m
//  ReachEngine
//
//  Created by Tom Irving on 20/09/2010.
//  Copyright 2010 Tom Irving. All rights reserved.
//

#import <UIKit/UIKit.h>

int main(int argc, char *argv[]) {
    
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    int retVal = UIApplicationMain(argc, argv, nil, @"ReachEngineAppDelegate");
    [pool release];
    return retVal;
}
